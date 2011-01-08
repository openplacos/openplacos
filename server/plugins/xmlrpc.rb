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

if File.symlink?(__FILE__)
  PATH =  File.dirname(File.readlink(__FILE__))
else 
  PATH = File.expand_path(File.dirname(__FILE__))
end

class XmlrpcPlugin < DBus::Object
  dbus_interface "org.openplacos.plugin" do

    dbus_method :server_ready do
      Thread.new do
        Thread.abort_on_exception = true
        require "#{PATH}/../../client/libclient/lib/server.rb"


        port = 8080
        opos = LibClient::Server.new
        server = XMLRPC::Server.new(port, '0.0.0.0')#, 150, $stderr)

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

        begin

          trap('INT'){
             Process.exit(0)
          }
            
          server.serve 

        end

        
        
        
      end
    end 
    
    dbus_method :quit do
      Process.exit(0)
    end  
    
  end
  
end 

if(ENV['DEBUG_OPOS'] ) ## Stand for debug
  bus =  DBus::session_bus
else
  bus = DBus::system_bus  
end
service = bus.request_service("org.openplacos.plugins.xmlrpc")
xmlrs = XmlrpcPlugin.new("/org/openplacos/plugin/xmlrpc")
service.export(xmlrs)
main = DBus::Main.new
main << bus
main.run


