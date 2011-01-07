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

require 'dbus'

#DBus
if(ENV['DEBUG_OPOS'] ) ## Stand for debug
  bus =  DBus::session_bus
  $INSTALL_PATH = File.dirname(__FILE__) + "/"
else
  bus = DBus::system_bus  
end
service = bus.request_service("org.openplacos.plugins.log")

file = "/tmp/log.txt"
if File.exists? file
  $log_file = File.open(file, "a+") 
else
  $log_file = File.new(file, "a+")
end

class Log < DBus::Object
  dbus_interface "org.openplacos.plugin" do

    dbus_method :create_measure, "in measure_name:s, in config:a{sv}" do |name, config|
      date = `date`
      date = date.chomp
      $log_file.write date +":" + "Create measure "+"#{name} #{config}" + "\n"
      $log_file.flush 
    end    

    dbus_method :create_actuator, "in actuator_name:s, in config:a{sv}" do |name, config|
      date = `date`
      date = date.chomp
      $log_file.write date +":" + "Create actuator "+"#{name} #{config}" + "\n"
      $log_file.flush 
    end    

    dbus_method :new_measure, "in measure_name:s, in value:v, in options:a{sv}" do |name, value, option|
      date = `date`
      date = date.chomp
      val = value.to_s
      $log_file.write date +":" + "New measure "+"#{name} #{val}" + "\n"
      $log_file.flush 
    end    

    dbus_method :new_order, "in actuator_name:s, in value:v, in options:a{sv}" do |name, order, option|
      date = `date`
      date = date.chomp
      ord  = order.to_s
      $log_file.write date +":" + "New order "+"#{name} #{ord}" + "\n"
      $log_file.flush 
    end    


  end
end


instance = Log.new("/org/openplacos/plugin/log")
service.export(instance)

main = DBus::Main.new
main << bus
main.run
