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

Bus = DBus::SystemBus.instance

# local include
require 'Dbus-interfaces.rb'


class Driver
  attr_reader :objects, :path_dbus

  #1 Name of service
  def initialize(card_ ) # Constructor

    # Class variables
    @name = card_["name"]
    @path_dbus = "org.openplacos.drivers." + card_["name"].downcase
    
    if Bus.service(@path_dbus).exists?
    
      @objects = Hash.new

      card_["plug"].each_pair do |pin,object_path|
        
        next if object_path.nil?

        # Get object proxy
        obj_proxy = Bus.introspect(@path_dbus, pin)
        @objects[pin]=obj_proxy
        
        # Welcome to Real Informatik
        # Here is a workaround to https://bugs.freedesktop.org/show_bug.cgi?id=25125
        obj_proxy.interfaces().each { |iface_name|
          obj_proxy[iface_name].methods.keys.each { |method|
            if (method == "read_"+ iface_name.split(".").reverse[0])
              $global.trace "redefine " + method + "() to read() for object " + pin
              aliasdef = "alias read " + "read_" + iface_name.split(".").reverse[0]
              obj_proxy[iface_name].instance_eval(aliasdef)
              obj_proxy[iface_name].methods["read"] =  obj_proxy[iface_name].methods["read_" + iface_name.split(".").reverse[0]]
            end
            
            if (method == "write_"+ iface_name.split(".").reverse[0])
              $global.trace "redefine " + method + "() to write() for object " + pin
              aliasdef = "alias write " + "write_" + iface_name.split(".").reverse[0]
              obj_proxy[iface_name].instance_eval(aliasdef)
              obj_proxy[iface_name].methods["write"] =  obj_proxy[iface_name].methods["write_" + iface_name.split(".").reverse[0]]
            end
          } 
        }
      end
      
    else
      abort "Can't find dbus service for card #{@name}"
    end

  end #  End of initialize

end # End of Driver




