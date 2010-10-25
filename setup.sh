#!/bin/sh

adduser openplacos --system -disabled-login -no-create-home
cp -rf ../openplacos/ /usr/lib/
ln -s /usr/lib/openplacos/server/Top.rb /usr/bin/openplacos-server
cp server/config_with_VirtualPlacos.yaml /etc/default/openplacos
cp setup_files/org.openplacos.drivers.virtualplacos.service /usr/share/dbus-1/services/
cp setup_files/openplacos.conf /etc/dbus-1/system.d/
cp setup_files/openplacos /etc/init.d/
update-rc.d openplacos defaults 98 02
