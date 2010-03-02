#!/usr/bin/env python
#-*- coding:utf-8 -*-

#
#
#

# Phidget specific imports
from Phidgets.PhidgetException import *
from Phidgets.Events.Events import *
from Phidgets.Manager import *
from Phidgets.Devices.InterfaceKit import *
from Phidgets.Devices.TextLCD import *
from Phidgets.Devices.Encoder import *


class PhidgetInterface(dbus.service.Object):
    """
        Accès aux interfaces Phidgets
    """
    
    def __init__(self, serial, index):
        
        self.serial = serial
        self.index = index
        self.path
        
        bus_name = dbus.service.BusName('org.openplacos.drivers', bus = dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '/org/openplacos/drivers/phidgets/' )

        # Attache de l'interface
        
