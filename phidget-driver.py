#!/usr/bin/env python
#-*- coding:utf-8 -*-

#
# Ecriture d'un driver phidgets python/dbus
#

import gobject
import dbus
import dbus.service
import dbus.glib

from Phidgets.Manager import *


BASE_PATH = '/org/openplacos/drivers/phidgets'
BASE_IFACE = 'org.openplacos.drivers.phidgets'


class PhidgetInterface(dbus.service.Object):
    """
        Accès aux interfaces Phidgets
    """
    
    def __init__(self, serial, index, path):
        
        self.serial = serial
        self.index = index
        
        bus_name = dbus.service.BusName('org.openplacos.server', bus = dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '%s/%s' %(BASE_PATH, path) )

        # Attache de l'interface
        
        

    #Event Handler Callback Functions
    def PhidgetDeviceAttached(e):
        attached = e.device
        print("Manager - Device %i: %s Attached!" % (attached.getSerialNum(), attached.getDeviceName()))

    def PhidgetDeviceDetached(e):
        detached = e.device
        print("Manager - Device %i: %s Detached!" % (detached.getSerialNum(), detached.getDeviceName()))

    def PhidgetError(e):
        print("Manager Phidget Error %i: %s" % (e.eCode, e.description))



class PhidgetSlot(dbus.service.Object):

    def __init__(self, serial, index, path):
        
        self.serial = serial
        self.index = index
        
        bus_name = dbus.service.BusName('org.openplacos.drivers', bus = dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '%s/%s' %(BASE_PATH, path) )


class PhidgetDigitalOutput(PhidgetSlot):
    """
        Cette classe représente une sortie digitale d'une carte phidget
    """
    
    def __init__(self, serial, index):
        PhidgetSlot.__init__(self, serial, index, '%s/outputs/digital/%s' % (serial, index) )

    
    @dbus.service.method('%s.output.digital' % BASE_IFACE )
    def read(self):

        return True

    @dbus.service.method('%s.output.digital' % BASE_IFACE, 'i')
    def write(self, value):

        return True



class PhidgetDigitalInput(PhidgetSlot):
    """
        Cette classe représente une entrée digitale d'une carte phidget
    """
    
    def __init__(self, serial, index):
        PhidgetSlot.__init__(self, serial, index, '%s/inputs/digital/%s' % (serial, index) )

    
    @dbus.service.method('%s.input.digital' % BASE_IFACE )
    def read(self):

        return True

    @dbus.service.method('%s.input.digital' % BASE_IFACE, 'i')
    def write(self, value):

        return False


class PhidgetAnalogInput(PhidgetSlot):
    """
        Cette classe représente une entrée analogique d'une carte phidget
    """

    def __init__(self, serial, index):
        PhidgetSlot.__init__(self, serial, index, '%s/inputs/analog/%s' % (serial, index) )


    @dbus.service.method('%s.input.analog' % BASE_IFACE)
    def read(self):

        return True

    @dbus.service.method('%s.input.analog' % BASE_IFACE, 'i')
    def write(self, value):

        return False


## En live..
if __name__ == "__main__":

    slots = []
    for i in range(0,8):
        slots.append(PhidgetDigitalOutput(123456, i))
    for i in range(0,8):
        slots.append(PhidgetDigitalInput(123456, i))
    for i in range(0,8):
        slots.append(PhidgetAnalogInput(123456, i))


        
    loop = gobject.MainLoop()
    print 'Listening'
    loop.run()

