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

# $INSTALL_PATH = File.dirname(__FILE__) + "/"
 $INSTALL_PATH = '/usr/lib/ruby/openplacos/server/'
$LOAD_PATH << $INSTALL_PATH 
ENV["DBUS_THREADED_ACCESS"] = "1" #activate threaded dbus


# List of library include
require 'yaml' 
require 'rubygems'
require 'dbus-openplacos'

# List of local include
require 'Driver.rb'
require 'Dbus-interfaces_acquisition_card.rb'
require 'Dbus_debug.rb'
require 'Measure.rb'
require 'Actuator.rb'
require 'Publish.rb'
require 'globals.rb'
require 'Regulation.rb'
require 'Plugin.rb'

#DBus
if(ENV['DEBUG_OPOS'] ) ## Stand for debug
  Bus = DBus::SessionBus.instance
  $INSTALL_PATH = File.dirname(__FILE__) + "/"
else
  Bus = DBus::SystemBus.instance
end

service = Bus.request_service("org.openplacos.server")

#Global functions
$global = Global.new


class Top

  attr_reader :drivers, :objects, :plugins, :dbus_plugins
  
  #1 Config file path
  #2 Dbus session reference
  def initialize (config_, service_)
    # Parse yaml
    @config =  YAML::load(File.read(config_))
    @service = service_

    # Config
    # Hash of available dbus drivers
    @drivers = Hash.new
    # Hash of available dbus objects (measures, actuators..)
    # the hash key is the dbus path
    @objects = Hash.new
    @plugins = Hash.new

    @dbus_plugins = Dbus_Plugin.new
    @service.export(@dbus_plugins)  
    
    # Launch required plugins
    if @config["plugins"]
      #export the dbus object for plugins 

      @plugin_main = DBus::Main.new
      @plugin_main << @service.bus
    
      # start a thread to listen on bus for reception of message
      plug_thread = Thread.new { @plugin_main.run }
      
      @config["plugins"].each do |plugin|
        @plugins.store(plugin["name"], Plugin.new(plugin, self))
      end
      
      @plugin_main.quit
      plug_thread.terminate
      @plugin_main = nil
      
    end
    

    # Create measures
    @config["objects"].each do |object|
    
      #detect model and merge with config
      if object["model"]
          #parse yaml
          #---
          # FIXME : model's yaml will be change, maybe
          #+++
          if File.exist?($INSTALL_PATH + "../components/sensors/" + object["model"] + ".yaml")
              model = YAML::load(File.read($INSTALL_PATH + "../components/sensors/" + object["model"] + ".yaml"))[object["model"]]
          elsif File.exist?($INSTALL_PATH + "../components/actuators/" + object["model"] + ".yaml")
              model = YAML::load(File.read($INSTALL_PATH + "../components/actuators/" + object["model"] + ".yaml"))[object["model"]]
          else
              abort "No model found for #{object['name']} : #{object['model']}"
          end
          #---
          # FIXME : merge delete similar keys, its not good for somes keys (like driver)
          #+++
          object = deep_merge(model,object)

          # Creates object from config and save it in @objects
          case object["informations"]["kind"]
            when "Sensor"
              @objects.store(object["path"], Measure.new(object, self))
              # Check dependencies
              @objects[object["path"]].sanity_check()
            when "Actuator"
              @objects.store(object["path"], Actuator.new(object, self))
          end     
      end
    end
    
    # For each acquisition driver
    @config["card"].each { |card|

      # Create driver proxy with standard acquisition card iface
      @drivers.store(card["name"], Driver.new(card,self))
      
      #infor the plugins that a new measure has been created
      @dbus_plugins.create_card(card["name"], card)

      # Push driver in DBus server config
      # Stand for debug
      card["plug"].each_pair{ |pin, object_path|

        next if object_path.nil?
        
        # plug proxy with dbus objects
        if @objects[object_path]
          @objects[object_path].plug(@drivers[card["name"]].objects[pin])
        end
        
        # For debug purposes
        #@service.export(Dbus_debug.new(object_path, @drivers[card["name"]].objects[object_path]))
      }
    }
    
    # Publish Objects on the bus
    @objects.each_value do |object|
      next if object.proxy_iface.nil?
      @service.export(Dbus_measure.new(object))  if object.is_a? Measure
      @service.export(Dbus_actuator.new(object)) if object.is_a? Actuator
    end

    @service.export(Server.new)

  end # End of init

  def measures
    measures = Hash.new
    @objects.each_pair do |path,object|
      measures[path] = object if object.is_a? Measure
    end
    return measures
  end

  def actuators
    actuators = Hash.new
    @objects.each_pair do |path,object|
      actuators[path] = object if object.is_a? Actuator
    end
    return actuators
  end

  private

  # used to merge models with config
  def deep_merge(oldhash,newhash)
    oldhash.merge(newhash) { |key, oldval ,newval|
      case oldval.class.to_s
      when "Hash"
        deep_merge(oldval,newval)
      when "Array"
        oldval.concat(newval)
      else
        newval
      end
    }
  end

end # End of Top

# Config file basic verification
if (ARGV[0] == nil)
  ARGV[0] = '/etc/default/openplacos'
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

# quit the plugins when server quit
trap('INT') do 
  top.dbus_plugins.quit
  Process.exit(0)
end

# server is now ready, send the information to plugin
Thread.new do
  sleep 1
  top.dbus_plugins.ready
end

# Let's Dbus have execution control
main = DBus::Main.new
main << Bus
main.run

