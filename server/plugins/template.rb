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


plugin.on_signal("create_measure") do |name,config|
  # do stuff when a measure is created
end

plugin.on_signal("create_actuator") do |name,config|
  # do stuff when an actuator is created
end

plugin.on_signal("new_measure") do |name, value, option|
  # do stuff when a measure is done
end

plugin.on_signal("new_order") do |name, order, option|
  # do stuff when a order is send
end

plugin.on_signal("ready") do
  # do stuff when the server is ready
end

plugin.on_signal("quit") do
  Process.exit(0)
end

#needed for signal reception
main = DBus::Main.new
main << clientbus
main.run
