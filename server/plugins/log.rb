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
  clientbus =  DBus::SessionBus.instance
else
  clientbus =  DBus::SystemBus.instance
end

server = clientbus.service("org.openplacos.server")

plugin = server.object("/plugins")
plugin.introspect
plugin.default_iface = "org.openplacos.plugins"


file = "/tmp/log.txt"
if File.exists? file
  $log_file = File.open(file, "a+") 
else
  $log_file = File.new(file, "a+")
end

plugin.on_signal("create_measure") do |name,config|
    date = Time.new.to_s
    $log_file.write date +":" + "Create measure "+"#{name} #{config.inspect}" + "\n"
    $log_file.flush 
end

plugin.on_signal("create_actuator") do |name,config|
    date = Time.new.to_s
    $log_file.write date +":" + "Create actuator "+"#{name} #{config}" + "\n"
    $log_file.flush 
end

plugin.on_signal("new_measure") do |name, value, option|
    date = Time.new.to_s
    val = value.to_s
    $log_file.write date +":" + "New measure "+"#{name} #{val}" + "\n"
    $log_file.flush 
end

plugin.on_signal("new_order") do |name, order, option|
    date = Time.new.to_s
    val = value.to_s
    $log_file.write date +":" + "New order "+"#{name} #{ord}" + "\n"
    $log_file.flush 
end

plugin.on_signal("quit") do
  Process.exit(0)
end

#needed for signal reception
main = DBus::Main.new
main << clientbus
main.run
