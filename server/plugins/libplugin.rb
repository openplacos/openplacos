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
ENV["DBUS_THREADED_ACCESS"] = "1" #activate threaded dbus
module Openplacos

  class Plugin
    attr_reader :name, :opos ,:main
    def initialize(name_)
      @server_ready_queue = Queue.new
      @name = name_
      #DBus
      if(ENV['DEBUG_OPOS'] ) ## Stand for debug
        @clientbus =  DBus::SessionBus.instance
      else
        @clientbus =  DBus::SystemBus.instance
      end

      server = @clientbus.service("org.openplacos.server")

      @opos = server.object("/plugins")
      @opos.introspect
      @opos.default_iface = "org.openplacos.plugins"
      
      @opos.on_signal("quit") do
        self.quit
      end
      
      @opos.on_signal("ready") do
        @server_ready_queue.push "Go"
      end
      
    end
    
    def run
      @main = DBus::Main.new
      @main << @clientbus
      @opos.plugin_is_ready(@name)
      @main.run
    end
    
    def quit
      @main.quit
      Process.exit(0)
    end

    def nonblock_run
      @mainthread = Thread.new{
        @main = DBus::Main.new
        @main << @clientbus
        @opos.plugin_is_ready(@name)
        @main.run
      }
      @server_ready_queue.pop
    end

  end


end
