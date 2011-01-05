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

require 'dbus'
require 'xmlrpc/server'
require "#{File.expand_path(File.dirname(__FILE__))}/../../libclient/lib/server.rb"


if ARGV.include?("-p")
  port = ARGV[ ARGV.index("-p") + 1]
else
  port = 8080
end

opos = LibClient::Server.new
server = XMLRPC::Server.new(port, '0.0.0.0', 150, $stderr)

server.add_handler("sensors") do
    opos.sensors.keys
end

server.add_handler("actuators") do
    opos.actuators.keys
end

server.add_handler("actuators.methods") do |path|
    opos.actuators[path].methods.keys
end

server.add_handler("objects") do
    opos.objects.keys
end

server.add_handler("get") do |path|
    opos.sensors[path].value[0]
end

server.add_handler("set") do |path, meth|
    eval "opos.actuators[\"#{path}\"].#{meth}"
end

server.serve
