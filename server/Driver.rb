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

# lib include
require 'dbus'
include REXML

Bus = DBus::SessionBus.instance

# local include
require 'Dbus-interfaces.rb'


class Driver
  attr_reader :objects

  #1 Name of service
  #2 Object listed in config
  #3 Ifaces that can be supported by this driver
  def initialize(card_, object_list_, ifaces_) # Constructor

    # Class variables
    @name = card_["name"]
    @path_dbus = card_["driver"]
    @interface = card_["interface"]
    @objects = Hash.new

    # Recognize standards objects
    object_list_.each { |pin|
      
      # Get object proxy
      obj_proxy = Bus.introspect(@path_dbus, pin)
      @objects[pin]=obj_proxy
      
      
      # Welcome to Real Informatik
      # Here is a workaround to https://bugs.freedesktop.org/show_bug.cgi?id=25125
      ifaces_.each_value { |iface|
        if obj_proxy.has_iface?(iface.get_name) 
          obj_proxy[iface.get_name].methods.keys.each { |method|
            if (method == "read_"+ iface.get_name)
              obj_proxy[iface.get_name].alias_method("read_"+ iface.get_name, "read")
            end
            
            if (method == "write_"+ iface.get_name)
              obj_proxy[iface.get_name].alias_method("write_"+ iface.get_name, "write")
            end
          } 
        end # if has_iface
      }
    }

  end #  End of initialize

end # End of Driver




