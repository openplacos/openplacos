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

path=`dirname $0`
temp_dir=`mktemp -d`

cd $temp_dir

git clone https://github.com/mvidner/ruby-dbus.git 
cd $temp_dir/ruby-dbus
git checkout -b multithreading origin/multithreading 
git reset --hard 89843b67e85a941317049d523a545042a4fddb07
rake gem
gem install $temp_dir/ruby-dbus/pkg/ruby-dbus-0.6.0.gem --no-ri --no-rdoc
rm -r -f $temp_dir


