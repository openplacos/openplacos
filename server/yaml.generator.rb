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

# List of library include
require 'yaml' 

# Here is a way to generate yaml properly

DRIVER = "org.openplacos.drivers.uchameleon"
OBJECT = {
  "/pin_1" => "device 1",
  "/pin_2" => "device 2",
  "/pin_3" => "device 3",
  "/pin_4" => "device 4",
  "/pin_5" => "device 5",
  "/pin_6" => "device 6",
  "/pin_7" => "device 7",
  "/pin_8" => "device 8",
  "/pin_9" => "device 9",
  "/pin_10" =>"device 10",
  "/pin_11" =>"device 11",
  "/pin_12" =>"device 12",
  "/pin_13" =>"device 13",
  "/pin_14" =>"device 14",
  "/pin_15" =>"device 15",
  "/pin_16" =>"device 16",
  "/pin_17" =>"device 17"}
INTERFACE = "org.openplacos.driver.uChamInterface"


card = {
  "driver"    => DRIVER,
  "interface" => INTERFACE,
  "object"    =>OBJECT
}

config = Array.new
config.push(card)
puts config.to_yaml
