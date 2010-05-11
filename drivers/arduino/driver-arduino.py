#!/usr/bin/env python
#-*- coding:utf-8 -*-
#
#    This file is part of Openplacos.
#
#    Openplacos is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Openplacos is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Openplacos.  If not, see <http://www.gnu.org/licenses/>.
#

#    Un driver Arduino/Firmata pour Openplacos
#    utilise python-firmata http://github.com/lupeke/python-firmata/
#


__version__   = "0.0.1"
__author__    = "lsdark, lsdark73@gmail.com"
__url__       = "http://openplacos.sourceforge.net/"
__copyright__ = "(c) 2010 lsdark"
__license__   = "GPL v3"


# Generic
import logging
import time
import yaml
import os

# DBUS
import gobject
import dbus
import dbus.service
import dbus.glib

# FIRMATA
import firmata

# Constantes
CONF_BASE_PATH = '/org/openplacos/drivers/arduino'
CONF_BASE_IFACE = 'org.openplacos.drivers.arduino'

class ArduinoDBusDriver(dbus.service.Object):
    """
        Accès à l'interface Arduino via Firmata
    """
    
    def __init__(self, loop, serial):
        """
            L'init du driver prend en argument la main loop utilisée pour dbus
            serial le port série à utiliser
        """
        
        self.MainLoop = loop
        self.serial = serial
        self.LogFile = "/tmp/driver-arduino.log"
        
        # Le driver déclare son interface sur dbus Session
        bus_name = dbus.service.BusName(CONF_BASE_IFACE, bus = dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, CONF_BASE_PATH )

        # les slots
        self.pins = []
        
        try:
            self.Arduino = firmata.Arduino(self.serial)
        except:
            logging.info("Erreur de Communication avec l'Arduino sur %s" % self.serial)
            exit(1)
        else:
             logging.info("Interface Arduino chargée (Firmata v%s.%s)" % \
                    (self.Arduino.major_version, self.Arduino.minor_version ) )
                    
        # On configure les pins
        filename = 'arduino-pins-conf.yml'
        if not os.path.exists(filename):
            raise NameError, "La config %s n'existe pas !" % filename
        f = open(filename, 'r')
        # Pour chaque pin du fichier de conf, on instancie un objet et on le configure

        for conf_pin in yaml.load(f):
            if conf_pin['type'] == 'digital':
                pin = ArduinoDigitalPin(self.Arduino, conf_pin['index'], conf_pin['mode'])
            elif conf_pin['type'] == 'analog':
                pin = ArduinoAnalogPin(self.Arduino, conf_pin['index'])
            else:
                # pas bon
                break
            
            self.pins.append(pin)
        # fermeture du fichier conf
        f.close()
        
        for pin in self.pins:
            print pin
        
    
    @dbus.service.method(CONF_BASE_IFACE)
    def quit(self):
        """
            Fermeture du driver
        """
        # on supprime la ref à l'Arduino
        self.Arduino = None
        # puis on quitte la boucle
        self.MainLoop.quit()

    ##
    ## Méthodes DBUS
    ##
    
    # TODO impléménter un mécanisme de callbacks            
        


class ArduinoDigitalPin(dbus.service.Object):
    """
        Cette classe représente une pin digitale d'un arduino
    """
    def __init__(self, interface, index, mode = 'OUTPUT'):
        
        self.interface = interface
        self.index = index
        self.state = None
        self.set_mode(mode)
        
        bus_name = dbus.service.BusName(CONF_BASE_IFACE, bus = dbus.SessionBus())
        path = '%s/digital/%s' % (CONF_BASE_PATH, index)
        dbus.service.Object.__init__(self, bus_name, path)


    # API test
    @dbus.service.method('org.openplacos.api.test', out_signature='b')
    def read_me(self):
        self.state = self.interface.digital_read(self.index)
        return self.state

    @dbus.service.method('org.openplacos.api.test', 'b')
    def write_me(self, value):
        if self.mode != firmata.OUTPUT:
            raise NameError("Pin non configurée en OUTPUT")
        if value : 
            value = firmata.HIGH
        else:
            value = firmata.LOW
            
        self.interface.digital_write(self.index, value)
    

    # API Openplacos
    @dbus.service.method('org.openplacos.api.digital', out_signature='b')
    def read(self):
        if not self.state:
            try: 
                self.state = self.interface.digital_read(self.index)
            except:
                logging.debug("Erreur de lecture de pin : %s" % self.index)
                # TODO : Exceptions D-Bus
                return False
        return self.state

    @dbus.service.method('org.openplacos.api.digital', 'b')
    def write(self, value):
        if self.mode != firmata.OUTPUT:
            raise NameError("Pin non configurée en OUTPUT")
        if value : 
            value = firmata.HIGH
        else:
            value = firmata.LOW
            
        try:
            self.interface.digital_write(self.index, value)
        except:
            logging.debug("Erreur d'écriture de pin : %s" % (self.index))
            return False
        self.state = value
        return True

    # API Arduino
    @dbus.service.method(CONF_BASE_IFACE, 's')
    def set_mode(self, mode):
        if mode == 'OUTPUT':
            self.mode = firmata.OUTPUT
        elif mode == 'INPUT':
            self.mode = firmata.INPUT
        else:
            raise NameError ("Choix de mode incorrect pour pin %s : %s" % (self.index, mode) )
        #try:
        self.interface.pin_mode(self.index, self.mode)
        #except:
        #    raise NameError ("Problème lors de set_mode %s pour pin %s" % (mode, self.index) )
    
    @dbus.service.method(CONF_BASE_IFACE, out_signature='s')
    def get_mode(self):
        if self.mode == firmata.OUTPUT:
            mode = 'OUTPUT'
        elif self.mode == firmata.INPUT:
            mode = 'INPUT'

        return mode
        
        
    # Auto str
    def __str__(self):
        return "%s mode:%s  index:%s  value:%s" % \
            (self.__class__.__name__, self.mode, self.index, self.read())

class ArduinoAnalogInput(dbus.service.Object):
    """
        Cette classe représente une entrée analogique d'une carte Arduino
    """
    def __init__(self, interface, index):
        
        self.interface = interface
        self.index = index
        
        bus_name = dbus.service.BusName(CONF_BASE_IFACE, bus = dbus.SessionBus())
        path = '%s/analog/input/%s' % (CONF_BASE_PATH, index)
        dbus.service.Object.__init__(self, bus_name, path)

    #
    # Interface générique analog
    #
    @dbus.service.method('org.openplacos.api.analog')
    def read(self):
        try: 
            value = self.interface.analog_read(self.index)
        except:
            logging.debug("Erreur de lecture analogique sur pin %s" % (self.index))
            return False
        return value

    @dbus.service.method('org.openplacos.api.analog', 'i')
    def write(self, value):
        #TODO : PWM ou objet PWM ?
        return False
            


## En live..
if __name__ == "__main__":

    logging.basicConfig(level=logging.DEBUG)
    loop = gobject.MainLoop()
    driver = ArduinoDBusDriver(loop, '/dev/ttyUSB0')
    print 'Listening'
    loop.run()
    print 'Good Bye !'
    
