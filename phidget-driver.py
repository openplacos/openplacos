#!/usr/bin/env python
#-*- coding:utf-8 -*-

#
# Ecriture d'un driver phidgets python/dbus
#

import gobject
import dbus
import dbus.service
import dbus.glib

class MyDBUSService(dbus.service.Object):

    def __init__(self):
        bus_name = dbus.service.BusName('org.openplacos.server', bus = dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '/org/openplacos/server/phidgets')

    @dbus.service.method('org.openplacos.server.phidgets.hello', 's')
    def hello(self, sender):
        """
            Test du service avec un Hello World!
        """
        return "Hello World, %s !" % sender

    @dbus.service.method('org.openplacos.server.phidgets.digital.read', 'ii')
    def digital_read(self, index, serial=None):
        """
            Lecture d'un entrée digitale 
        """
        return True

    @dbus.service.method('org.openplacos.server.phidgets.digital.write', 'iii')
    def digital_write(self, index, value, serial=None):
        """
            Ecriture d'une sortie digitale
        """
        return True


## En live..
if __name__ == "__main__":

    obj = MyDBUSService()
    loop = gobject.MainLoop()
    print 'Listening'
    loop.run()

