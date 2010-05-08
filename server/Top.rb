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
require 'Request.rb'

# List of library include
require 'yaml' 

#DBus
sessionBus = DBus::session_bus
service = sessionBus.request_service("org.openplacos.server")

# Parse yaml
driver = Hash.new
config =  YAML::load(File.read('config.yaml'))

# Configure all the driver
config.each { |card|

  # Get object list
  object_list = Array.new
  card["object"].each_value{ |obj|
    object_list.push("/" + obj)
  }
  driver.store(card["name"], Driver_object.new( card["name"], card["driver"], card["interface"], object_list))
 

  # DBus server config
  card["object"].each_pair{ |device, pin|
  exported_obj = Request.new(device, driver[card["name"]].pins["/"+pin])
  service.export(exported_obj)
  }
}



main = DBus::Main.new
main << sessionBus
main.run


# Tests functions
#puts  driver["uCham"].pins["/pin_14"].get_service("read_analog").call()

#10.times {
#  driver["uCham"].pins["/pin_14"].get_service("write_boolean").call(true)
#  sleep 2
#  driver["uCham"].pins["/pin_14"].get_service("write_boolean").call(false)
#  sleep 2
#}
