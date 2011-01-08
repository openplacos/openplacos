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

openplacos_core_version="0"
openplacos_core_subversion="0.1"
path=`dirname $0`

# Fonction: installation
dependencies() {
  # Pre-requis
  echo "----------------------------------------------------"
  echo "Dependencies installation"
  echo "----------------------------------------------------"
  apt-get install git-core ruby ruby1.8-dev rubygems 
  gem install rubygems-update --no-ri --no-rdoc
  /var/lib/gems/1.8/bin/update_rubygems 
  gem update --no-ri --no-rdoc
  echo "----------------------------------------------------"
  echo "Ruby gem lib installation "
  echo "This could take about 10 min -- please wait"
  echo "----------------------------------------------------"
  gem install activerecord mysql serialport --no-ri --no-rdoc
}

installation() {
  # User openplacos
  echo "----------------------------------------------------"
  echo "User OpenplacOS"
  echo "----------------------------------------------------"
  adduser openplacos --system -disabled-login -no-create-home
  echo "openplacos user added"
 
  # sources wget
  # echo "----------------------------------------------------"
  # echo "source download"
  # echo "OpenplacOS version:   $openplacos_core_subversion"
  # echo "----------------------------------------------------"
  # mkdir ~/$0
  # cd ~/$0
  # wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-$nagios_core_subversion.tar.gz
  # tar -xzf nagios-$nagios_core_subversion.tar.gz


  # Files copies
  echo "----------------------------------------------------"
  echo "File copy in your system"
  echo "----------------------------------------------------"
  cp -rf $path/../openplacos/ /usr/lib/ruby/

# link into path
  ln -s -f /usr/lib/ruby/openplacos/server/Top.rb /usr/bin/openplacos-server
  ln -s -f /usr/lib/ruby/openplacos/client/CLI_client/opos-client.rb /usr/bin/openplacos
  ln -s -f /usr/lib/ruby/openplacos/client/IHMlocal/IHM.rb /usr/bin/openplacos-gtk
  ln -s -f /usr/lib/ruby/openplacos/client/xml-rpc/client/xml-rpc-client.rb  /usr/bin/openplacos-xmlrpc
  ln -s -f /usr/lib/ruby/openplacos/client/soap/client/soap-client.rb  /usr/bin/openplacos-soap
  ln -s -f /usr/lib/ruby/openplacos/client/xml-rpc/server/xml-rpc-server.rb  /usr/bin/openplacos-server-xmlrpc
  ln -s -f /usr/lib/ruby/openplacos/client/soap/server/soap-server.rb  /usr/bin/openplacos-server-soap  
  
# default config
  cp $path/server/config_with_VirtualPlacos.yaml /etc/default/openplacos

# dbus integration
  cp $path/setup_files/*.service /usr/share/dbus-1/system-services/
  cp $path/setup_files/openplacos.conf /etc/dbus-1/system.d/

# Start with system
  cp $path/setup_files/openplacos /etc/init.d/
  update-rc.d openplacos defaults 98 02

 
 # Remove temporary files
  # cd ~
  # rm -rf ~/$0 


}

# Fonction: Check config file -- To be implemented
check() {
  echo "----------------------------------------------------"
  echo "OpenplacOS config file check"
  echo "----------------------------------------------------"
#  /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
}   

# OpenplacOS startup
start() {
  echo "----------------------------------------------------"
  echo "OpenplacOS startup"
  echo "----------------------------------------------------"
  /etc/init.d/openplacos start
  echo "URL administration: http://localhost/openplacos/"
}

# Main
if [ "$(id -u)" != "0" ]; then
	echo "Root permission needed"
	echo "Syntax: sudo $0"
	exit 1
fi

if [ "$1" = "-nodep" ]
then
    echo "No dep installed"
else
   dependencies 
fi

installation
check
start

