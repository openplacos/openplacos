#!/usr/bin/env python
#-*- coding:utf-8 -*-

#
#
#

# Generic
import logging
import time

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


class PhidgetInterface(dbus.service.Object):
    """
        Accès aux interfaces Phidgets
    """
    
    def __init__(self, name, serial):
        
        self.name = name
        self.serial = serial

        self.logfile = "phidgets.log"

        bus_name = dbus.service.BusName('org.openplacos.drivers.phidgets', bus = dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '/org/openplacos/drivers/phidgets' )

        # Attache de(s) l'interface
        self.devices = []
        
        phidget = InterfaceKit()
        phidget.enableLogging(PhidgetLogLevel.PHIDGET_LOG_VERBOSE, self.logfile)
        phidget.setOnAttachHandler(self.phidget_attach_handler)
        phidget.setOnDetachHandler(self.phidget_detach_handler)
        phidget.openPhidget(self.serial)
        try:
            phidget.waitForAttach(2000)
        except PhidgetException as e:
            print("Phidget Exception %i: %s" % (e.code, e.details))
            print("Exiting....")
            exit(1)
            
        self.devices.append(phidget)
    
    def manager(self):
        """
            Cette méthode permet d'interroger les phidgets connectés 
        """
        # on commence par fermer tous les phidgets ouverts
        #for phidget in self.devices:
        #    if phidget.isAttached(): phidget.closePhidget()
        mgr = Manager()
        mgr.openManager()
        attachedDevices = mgr.getAttachedDevices()
        print("|------------|----------------------------------|--------------|------------|")
        print("|- Attached -|-              Type              -|- Serial No. -|-  Version -|")
        print("|------------|----------------------------------|--------------|------------|")
        for attachedDevice in attachedDevices:
            print("|- %8s -|- %30s -|- %10d -|- %8d -|" % (attachedDevice.isAttached(), attachedDevice.getDeviceType(), attachedDevice.getSerialNum(), attachedDevice.getDeviceVersion()))

        print("|------------|----------------------------------|--------------|------------|")

    
        
    ##
    ## Phidgets Attach/Detach handlers
    ##
    def phidget_attach_handler(self, e):
        """ Handler de phidget attaché """
        attached = e.device
        print ("Attach %s : %s" % (attached.getDeviceType(), attached.getSerialNum() ) )
    
    def phidget_detach_handler(self, e):
        """ Handler de phidget détaché """
        detached = e.device
        print ("Detach %s : %s" % (detached.getDeviceType(), detached.getSerialNum() ) )




## En live..
if __name__ == "__main__":

    logging.basicConfig(level=logging.DEBUG)
    phidgets = PhidgetInterface("8/8/8", 77225) 
    phidgets.manager()
   
    
