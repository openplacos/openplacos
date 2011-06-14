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
apt_dependencies() {
  # Pre-requis

  apt-get install ruby ruby1.8-dev rubygems libmysqlclient-dev 

}

gem_dependencies() {
  # opos bundle install
  echo "----------------------------------------------------"
  echo "Ruby gem lib installation "
  echo "This could take about 10 min -- please wait"
  echo "----------------------------------------------------"

  gem install bundler --bindir /usr/bin --no-ri --no-rdoc
  cd /usr/lib/ruby/openplacos
  bundle install

  # rails bundle install
  echo "----------------------------------------------------"
  echo "rails bundle installation "
  echo "This could take about 10 min -- please wait"
  echo "----------------------------------------------------"

  cd /usr/lib/ruby/openplacos/plugins/rorplacos/
  bundle install
}

installation() {
  # Files copies
  mkdir /usr/lib/ruby/openplacos
  cp -f COPYING /usr/lib/ruby/openplacos/COPYING
	cp -f README /usr/lib/ruby/openplacos/README
	cp -f Gemfile /usr/lib/ruby/openplacos/Gemfile
	
	cp -rf server /usr/lib/ruby/openplacos
	cp -rf clients /usr/lib/ruby/openplacos
	cp -rf components /usr/lib/ruby/openplacos
	cp -rf plugins /usr/lib/ruby/openplacos
	cp -rf drivers /usr/lib/ruby/openplacos
  
  # default config
  if [ -e /etc/default/openplacos ]
  then
    echo "config file already exist"
  else  
    cp $path/server/config_with_VirtualPlacos.yaml /etc/default/openplacos
  fi 

  mkdir /usr/lib/ruby/openplacos/plugins/rorplacos/tmp
  chown -R openplacos /usr/lib/ruby/openplacos/plugins/rorplacos/tmp
  chown -R openplacos /usr/lib/ruby/openplacos/plugins/rorplacos/log
}

mysql_install() {

    apt-get install mysql-server
    echo "----------------------------------------------------"
    echo "Process database configuration" 
    echo "Please provide MySQL root password" 
    echo "----------------------------------------------------"  
    mysql -u root -p < $path/setup_files/install.sql
}

post_installation() {
  # User openplacos
  adduser openplacos --system -disabled-login -no-create-home
  adduser openplacos dialout


# link into path
    ln -s -f /usr/lib/ruby/openplacos/server/main.rb /usr/bin/openplacos-server
    ln -s -f /usr/lib/ruby/openplacos/clients/CLI_client/opos-client.rb /usr/bin/openplacos
    ln -s -f /usr/lib/ruby/openplacos/clients/xml-rpc/xml-rpc-client.rb  /usr/bin/openplacos-xmlrpc
    ln -s -f /usr/lib/ruby/openplacos/clients/soap/soap-client.rb  /usr/bin/openplacos-soap

# dbus integration
  cp $path/setup_files/*.service /usr/share/dbus-1/system-services/
  cp $path/setup_files/openplacos.conf /etc/dbus-1/system.d/

# reload dbus
  /etc/init.d/dbus reload

# Start with system
  cp $path/setup_files/openplacos /etc/init.d/
  update-rc.d openplacos defaults 98 02
}

   

# OpenplacOS startup
start() {
  /etc/init.d/openplacos start
  echo "URL administration: http://localhost:3000"
}

# For testing only
print_help_infos () {
    echo ""
}

# Main
if [ "$(id -u)" != "0" ]; then
	echo "Root permission needed"
	echo "Syntax: sudo $0"
	exit 1
fi

echo "Do you want to install apt dependencies on your system ? [Y/n]"
read dep
if [ "$dep" = n ]
then
    echo "No dep installed"
else
   apt_dependencies 
fi

echo "Do you want to copy files on your system ? [Y/n]"
read copy
if [ "$copy" = "n" ]
then
    echo "http://openplacos.tuxfamily.org/V1.0/?q=content/launch-openplacos-debug-mode"
else
    installation
fi

echo "Do you want to install gem dependencies on your system ? [Y/n]"
read dep
if [ "$dep" = n ]
then
    echo "No dep installed"
else
   gem_dependencies 
fi

echo "Do you want to proceed an easy and automatic MySQL install [y/N]"
read answer
if [ "$answer" = "y" ]
then
    mysql_install
fi

if [ "$copy" = "y" ]
then
    post_installation
    start
else
    echo "You choose no integration - please launch by hand"
    print_help_infos
fi


