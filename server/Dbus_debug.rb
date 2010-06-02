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
include REXML

# List of local include
require 'Dbus-interfaces_acquisition_card.rb'



class Dbus_debug < DBus::Object
  # Create an interface.
  dbus_interface "org.openplacos.server.Interface" do
    # Create generic interface

    dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
      if (value.class==TrueClass) or (value.class==FalseClass)
        return @proxy[$card_ifaces["digital"].get_name].write(value, option)
      else
        return @proxy[$card_ifaces["analog"].get_name].write(value, option)
      end 
    end # End of dbus_method :write
    
    dbus_method :read_analog, "out return:v, in option:a{sv}" do  |option|
      return @proxy[$card_ifaces["analog"].get_name].read(option)
    end  # End of dbus_method :read_analog
    
    dbus_method :read_digital, "out return:v, in option:a{sv}" do  |option|
      return @proxy[$card_ifaces["digital"].get_name].read(option)
    end # End of dbus_method :read_digital
    
  end # End of dbus_interface
  
  #1 Dbus serive path
  #2 proxy object to debug
  def initialize (path_, proxy_obj_)
    # DBus constructor
    super(path_)
    
    @proxy = proxy_obj_
  end # End of initialize

end # End of class Dbus_debug 

