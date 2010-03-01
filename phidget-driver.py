#!/usr/bin/env python
#-*- coding:utf-8 -*-

#
# Ecriture d'un driver phidgets python/dbus
#


class Example(dbus.service.Object):
    def __init__(self, object_path):
        dbus.service.Object.__init__(self, dbus.SessionBus(), path)



