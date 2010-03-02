#!/usr/bin/env python
#-*- coding:utf-8 -*-

#
#
#

# Generic
import logging


# DBUS
import gobject
import dbus
import dbus.service
import dbus.glib


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
    
    def __init__(self, name, serial):
        
        self.name = name
        self.serial = serial

        self.logfile = "phidgets.log"

        bus_name = dbus.service.BusName('org.openplacos.drivers', bus = dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '/org/openplacos/drivers/phidgets/' )

        # Attache de l'interface
        self.interface = InterfaceKit()
        self.interface.enableLogging(PhidgetLogLevel.PHIDGET_LOG_VERBOSE, self.logfile)
        
        self.interface.setOnAttachHandler(self.phidget_attach_handler)
        self.interface.setOnDetachHandler(self.phidget_detach_handler)
        self.interface.openPhidget(self.serial)
        
        
    ##
    ## Phidgets Attach/Detach handlers
    ##
    def phidget_attach_handler(self, e):
        """ Handler de phidget attaché """
        attached = e.device
        logging.debug("Attach %s : %s" % (attached.getDeviceType(), attached.getSerialNum() ) )
    
    def phidget_detach_handler(self, e):
        """ Handler de phidget détaché """
        detached = e.device
        logging.debug("Detach %s : %s" % (detached.getDeviceType(), detached.getSerialNum() ) )

