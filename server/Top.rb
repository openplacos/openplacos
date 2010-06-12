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
require 'Actuator.rb'
require 'Publish.rb'
require 'globals.rb'

# List of library include
require 'yaml' 

#DBus
sessionBus = DBus::session_bus
service = sessionBus.request_service("org.openplacos.server")

#Global functions
$global = Global.new


class Top
  attr_reader :measure, :actuator
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
    @actuator = Hash.new
    
    # Create measures
    if @config["measure"]
      @config["measure"].each { |meas|
        @measure.store(meas["name"], Measure.new(meas, self))
      }

      # Check dependencies
      @measure.each_value{ |meas|
        meas.sanity_check()
      }
      
    end
    
    #create actuators
    if @config["actuator"]
      @config["actuator"].each { |act|
        $global.trace "Actuator: " + act["name"]
        @actuator.store(act["name"], Actuator.new(act, self))
      }
    else
      puts "No actuators where defined in config"
    end
    
    # For each acquisition driver
    @config["card"].each { |card|

      # Get object list mapped in array
      object_list = Array.new
      card["plug"].each_key{ |obj|
        object_list.push("/" + obj)
      }

      # Create driver proxy with standard acquisition card iface
      @driver.store(card["name"], Driver.new( card, object_list))
      

      # Push driver in DBus server config
      # Stand for debug
      card["plug"].each_pair{ |obj, device|

        # plug proxy with measure 
        if @measure[device]
          @measure[device].plug(@driver[card["name"]].objects["/"+obj])
        end

        # plug proxy with actuator
        if @actuator[device]
          @actuator[device].plug(@driver[card["name"]].objects["/"+obj])
        end

        
        exported_obj = Dbus_debug.new(device,@driver[card["name"]].objects["/"+obj])
        @service.export(exported_obj)
      }
    }
    
    
    # Publish measures on Dbus
    @measure.each_value{ |measure|
      exported_obj = Dbus_measure.new(measure)
      @service.export(exported_obj)
    }
    
    # Publish actuators on Dbus
    @actuator.each_value{ |act|
      exported_obj = Dbus_actuator.new(act)
      @service.export(exported_obj)
    }

  end # End of init
end # End of Top

# Config file basic verification
if (ARGV[0] == nil)
  puts "Please specify a config file"
  puts "Usage: openplacos-server <config-file>"
  Process.exit 1
end

if (! File.exist?(ARGV[0]))
  puts "Config file " +ARGV[0]+" doesn't exist"
  Process.exit 1
end


if (! File.readable?(ARGV[0]))
  puts "Config file " +ARGV[0]+" not readable"
  Process.exit 1
end

# Construct Top
top = Top.new(ARGV[0], service)

# Let's Dbus have execution control
main = DBus::Main.new
main << sessionBus
main.run


