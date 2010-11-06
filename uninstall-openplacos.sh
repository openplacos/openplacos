#!/bin/sh
#
#    This file is part of Openplacos.
#
#    Openplacos is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
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

# Automatic install of OpenplacOS under Ubuntu 10.10
# HowTo: # sudo ./openplacosautoinstall-ubuntu.sh
# Inspirated by http://svn.nicolargo.com/nagiosautoinstall/trunk/nagiosautoinstall-ubuntu.sh

version="0.1"


# Fonction: uninstallation
uninstallation() {
 
  # User openplacos
  echo "----------------------------------------------------"
  echo "Remove user OpenplacOS"
  echo "----------------------------------------------------"
  userdel openplacos
  echo "openplacos user deleted"

  # Files copies
  echo "----------------------------------------------------"
  echo "File remove in system"
  echo "----------------------------------------------------"
  rm -rf /usr/lib/ruby/openplacos/
  rm /usr/bin/openplacos-server
  rm /usr/share/dbus-1/system-services/org.openplacos.drivers.*
  rm /etc/dbus-1/system.d/openplacos.conf
  rm /etc/init.d/openplacos
  update-rc.d openplacos disable

}

# Fonction: Check config file -- To be implemented
check() {
  # echo "----------------------------------------------------"
  # echo "OpenplacOS config file check"
  # echo "----------------------------------------------------"
#  /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
}   

# OpenplacOS stop
stop() {
  echo "----------------------------------------------------"
  echo "OpenplacOS stop"
  echo "----------------------------------------------------"
  /etc/init.d/openplacos stop

}

# Main
if [ "$(id -u)" != "0" ]; then
	echo "Root permission needed"
	echo "Syntax: sudo $0"
	exit 1
fi
stop
uninstallation
check


