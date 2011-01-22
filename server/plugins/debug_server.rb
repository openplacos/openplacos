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


# this is a debug server for plugins

ENV["DBUS_THREADED_ACCESS"] = "1" #activate threaded dbus
require 'rubygems'
require 'dbus'

if(ENV['DEBUG_OPOS'] ) ## Stand for debug
  bus =  DBus::session_bus
else
  bus = DBus::system_bus  
end
$config = Hash.new
service = bus.request_service("org.openplacos.server")

class Dbus_Plugin < DBus::Object

  dbus_interface "org.openplacos.plugins" do
    dbus_signal :create_measure, "in measure_name:s, in config:a{sv}"
    dbus_signal :create_actuator, "in actuator_name:s, in config:a{sv}"
    dbus_signal :new_measure, "in measure_name:s, in value:v, in options:a{sv}"
    dbus_signal :new_order, "in actuator_name:s, in value:v, in options:a{sv}"
    dbus_signal :error, "in error:s, in option:a{sv}"
    dbus_signal :quit,""
    dbus_signal :ready,""
    dbus_method :plugin_is_ready, "in name:s" do |name|
      puts "Plugin named #{name} is started"
    end 
    dbus_method :getConfig, "out return:a{sv}" do
      [$config]
    end  
  end
  
  
end

class Call < DBus::Object

  dbus_interface "org.openplacos.call" do
    dbus_method :create_measure, "in measure_name:s, in config:a{sv}" do |meas, config|
      Thread.new{$plugins.create_measure(meas,config)}
      return
    end
    dbus_method :create_actuator, "in actuator_name:s, in config:a{sv}" do |act ,config|
      Thread.new{$plugins.create_actuator(act,config)}
      return
    end
    
    dbus_method :new_measure, "in measure_name:s, in value:v, in options:a{sv}" do |meas ,value,options|
      Thread.new{$plugins.new_measure(meas,value,options)}
      return
    end
    
    dbus_method :new_measure, "in measure_name:s, in value:v, in options:a{sv}" do |meas ,value,options|
      Thread.new{$plugins.new_measure(meas,value,options)}
      return
    end
    
    dbus_method :new_order, "in actuator_name:s, in value:v, in options:a{sv}" do |act,value,options|
      Thread.new{$plugins.new_order(act,value,options)}
      return
    end
    
    dbus_method :error, "in error:s, in options:a{sv}" do |err,options|
      Thread.new{$plugins.error(err,options)}
      return
    end
    
    dbus_method :quit do 
      Thread.new{$plugins.quit}
      return
    end
    
    dbus_method :ready do 
      Thread.new{$plugins.ready}
      return
    end
    
    dbus_method :setConfig, "in config:a{sv}" do |config|
      $config = config
    end  
    
  end

end

$plugins = Dbus_Plugin.new("/plugins")
service.export($plugins)

call = Call.new("call")
service.export(call)

main = DBus::Main.new
main << bus
main.run


