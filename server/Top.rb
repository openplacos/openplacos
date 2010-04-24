#/usr/bin/ruby -w

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


# List of local include
require 'Driver_object.rb'


# List of library include



#Configuration 

DRIVER = "org.openplacos.drivers.uChameleon"
OBJECT = ["/pin_1", "/pin_2","/pin_3", "/pin_4", "/pin_5", "/pin_6",  "/pin_7", "/pin_8", "/pin_9", "/pin_10",  "/pin_11", "/pin_12", "/pin_13", "/pin_14", "/pin_15", "/pin_16", "/pin_17"]
INTERFACE = "org.openplacos.driver.uChamInterface"
#METHODE = "Write_b"


driver = Driver_object.new "uCham", DRIVER, OBJECT, INTERFACE
