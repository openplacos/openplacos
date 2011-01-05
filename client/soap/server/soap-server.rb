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
require 'rubygems'
require "soap/rpc/standaloneServer"

if ENV['DEBUG_OPOS']
  require '../../libclient/libclient.rb'
else
  $: << "/usr/lib/ruby/openplacos/client/libclient/" 
  require "libclient.rb"
end

if ARGV.include?("-p")
  port = ARGV[ ARGV.index("-p") + 1]
else
  port = 8080
end



begin
   class MySoapServer < SOAP::RPC::StandaloneServer

      # Expose our services
      def initialize(opos_,*args)
        @opos = opos_
        super(*args)
         add_method(self, 'sensors')
         add_method(self, 'actuators')
         add_method(self, 'actuators_methods','path')
         add_method(self, 'objects')
         add_method(self, 'get','path')
         add_method(self, 'set_a','path','meth')  #cant use set for methode name
      end
      
      def sensors
        @opos.sensors.keys
      end
    
      def actuators
        @opos.actuators.keys
      end
      
      def actuators_methods(path)
        @opos.actuators[path].methods.keys
      end
     
      def objects
        @opos.objects.keys
      end
      
      def get(path)
        @opos.sensors[path].value[0]
      end

      def set_a(path,meth)
        @opos.actuators[path].method(meth).call
      end

  end
  
  opos = LibClient::Server.new
  
  server = MySoapServer.new(opos,"MySoapServer", 
            'urn:ruby:opos', '0.0.0.0', port)
  trap('INT'){
     server.shutdown
  }
  server.start
rescue => err
  puts err.message
end

