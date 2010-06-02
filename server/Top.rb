#!/usr/bin/ruby -w

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
require 'Driver.rb'
require 'Dbus-interfaces_acquisition_card.rb'
require 'Dbus_debug.rb'
require 'Measure.rb'

# List of library include
require 'yaml' 

#DBus
sessionBus = DBus::session_bus
service = sessionBus.request_service("org.openplacos.server")

class Top
  attr_reader :measure
  attr_reader :driver
  
  #1 Config file path
  #2 Dbus session reference
  def initialize (config_, service_)
    # Parse yaml
    @config =  YAML::load(File.read(config_))
    @service = service_

    # Config 
    @driver = Hash.new
    @measure = Hash.new

    # Create measures
    @config["measure"].each { |meas|
      @measure.store(meas["name"], Measure.new(meas, self))
    }

    # Check dependencies
    @measure.each_value{ |meas|
      meas.sanity_check()
    }

    # For each acquisition driver
    @config["card"].each { |card|

      # Get object list mapped in array
      object_list = Array.new
      card["object"].each_value{ |obj|
        object_list.push("/" + obj)
      }
      # Create driver proxy with standard acquisition card iface
      @driver.store(card["name"], Driver.new( card, object_list, $card_ifaces))
      
      # Push driver in DBus server config
      # Stand for debug
      card["object"].each_pair{ |device, pin|
        exported_obj = Dbus_debug.new(device, driver[card["name"]].objects["/"+pin])
        @service.export(exported_obj)
      }
    }

  end # End of init
end # End of Top

# Config file basic verification
if (ARGV[0] == nil)
  puts "Please specify a config file"
  puts "Usage: openplacos-server <config-file>"
  Process.exit
end

if (! File.exist?(ARGV[0]))
  puts "Config file " +ARGV[0]+" doesn't exist"
  Process.exit
end


if (! File.readable?(ARGV[0]))
  puts "Config file " +ARGV[0]+" not readable"
  Process.exit
end

# Construct Top
top = Top.new(ARGV[0], service)

# Let's Dbus have execution control
main = DBus::Main.new
main << sessionBus
main.run


