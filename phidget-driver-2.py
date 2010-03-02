#!/usr/bin/env python
#-*- coding:utf-8 -*-

#
#
#

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


# Phidget specific imports
from Phidgets.Phidget import PhidgetLogLevel
from Phidgets.PhidgetException import *
from Phidgets.Events.Events import *
from Phidgets.Manager import *
from Phidgets.Devices.InterfaceKit import *
from Phidgets.Devices.TextLCD import *
from Phidgets.Devices.Encoder import *

# Constantes
CONF_BASE_PATH = '/org/openplacos/drivers/phidgets'
CONF_BASE_IFACE = 'org.openplacos.drivers.phidgets'

class PhidgetsDBUSDriver(dbus.service.Object):
    """
        Accès aux interfaces Phidgets
    """
    
    def __init__(self):
       
        self.logfile = "phidgets.log"

        bus_name = dbus.service.BusName(CONF_BASE_IFACE, bus = dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, CONF_BASE_PATH )

        # les devices et les slots
        self.devices = []
        self.slots = []
        
        # On charge la conf depuis un fichier YAML
        filename = "driver-conf.yml"
        if not os.path.exists(filename):
            raise NameError, "La config %s n'existe pas !" % filename
        f = open(filename, 'r')
        config = yaml.load(f.read())
        f.close()
        for obj in config :
            # on instancie le type définit dans le yaml
            exec ("device = %s()" % (obj['type']) )
            device.enableLogging(PhidgetLogLevel.PHIDGET_LOG_VERBOSE, self.logfile)
            device.setOnAttachHandler(self.phidget_attach_handler)
            device.setOnDetachHandler(self.phidget_detach_handler)
            device.openPhidget( obj['serial'])
            # TODO : enlever les refs a waitForAttach()
            device.waitForAttach(2000)
        self.devices.append(device)

    
    def close(self):
        """
            Fermeture du driver
        """
        # on commence par fermer tous les phidgets ouverts : plus nécessaire apparement
        for phidget in self.devices:
            if phidget.isAttached():
                try:
                    phidget.closePhidget()
                except PhidgetException as e:
                    print("Phidget Exception %i: %s" % (e.code, e.details))
                    print("Exiting....")
                    exit(1)

    ##
    ## Méthodes DBUS
    ##

        
    ##
    ## Phidgets Attach/Detach handlers
    ##
    def phidget_attach_handler(self, e):
        """ Handler de phidget attaché """
        attached = e.device
        print ("Attach %s : %s" % (attached.getDeviceType(), attached.getSerialNum() ) )
        # TODO : publier l'interface sur le bus
        # On crée un slot par E/S
        if attached.getDeviceType() == "PhidgetInterfaceKit" :
            for i in range(0, attached.getOutputCount() ):
                print "Output %s " % i
                self.slots.append(PhidgetDigitalOutput(attached.getSerialNum(), i ))
            for i in range(0, attached.getInputCount() ):
                print "Input %s " % i
                self.slots.append(PhidgetDigitalInput(attached.getSerialNum(), i ))
            for i in range(0, attached.getSensorCount() ):
                print "Sensor %s " % i
                self.slots.append(PhidgetAnalogInput(attached.getSerialNum(), i ))
    
    def phidget_detach_handler(self, e): 
        """ Handler de phidget détaché """
        detached = e.device
        print ("Detach %s : %s" % (detached.getDeviceType(), detached.getSerialNum() ) )
        # TODO : retirer l'interface du bus



class PhidgetSlot(dbus.service.Object):

    def __init__(self, serial, index, path):
        
        self.serial = serial
        self.index = index
        
        bus_name = dbus.service.BusName(CONF_BASE_IFACE, bus = dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '%s/%s' %(CONF_BASE_PATH, path) )


class PhidgetDigitalOutput(PhidgetSlot):
    """
        Cette classe représente une sortie digitale d'une carte phidget
    """
    def __init__(self, serial, index):
        PhidgetSlot.__init__(self, serial, index, '%s/outputs/digital/%s' % (serial, index) )

    @dbus.service.method('%s.output.digital' % CONF_BASE_IFACE )
    def read(self):
        return True

    @dbus.service.method('%s.output.digital' % CONF_BASE_IFACE, 'i')
    def write(self, value):
        return True



class PhidgetDigitalInput(PhidgetSlot):
    """
        Cette classe représente une entrée digitale d'une carte phidget
    """
    def __init__(self, serial, index):
        PhidgetSlot.__init__(self, serial, index, '%s/inputs/digital/%s' % (serial, index) )

    @dbus.service.method('%s.input.digital' % CONF_BASE_IFACE )
    def read(self):
        return True

    @dbus.service.method('%s.input.digital' % CONF_BASE_IFACE, 'i')
    def write(self, value):
        return False


class PhidgetAnalogInput(PhidgetSlot):
    """
        Cette classe représente une entrée analogique d'une carte phidget
    """
    def __init__(self, serial, index):
        PhidgetSlot.__init__(self, serial, index, '%s/inputs/analog/%s' % (serial, index) )

    @dbus.service.method('%s.input.analog' % CONF_BASE_IFACE)
    def read(self):
        return True

    @dbus.service.method('%s.input.analog' % CONF_BASE_IFACE, 'i')
    def write(self, value):
        return False



## En live..
if __name__ == "__main__":

    logging.basicConfig(level=logging.DEBUG)
    driver = PhidgetsDBUSDriver()

    loop = gobject.MainLoop()
    print 'Listening'
    loop.run()

    driver.close()
    
