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




class Request < DBus::Object
  # Create an interface.
  dbus_interface "org.openplacos.server.Interface" do
    # Create generic interface
    dbus_method :write_boolean, "in arg:b" do |arg|
      @pin_obj.get_service("write_boolean").call(arg)
    end
    dbus_method :read_boolean, "out arg:b" do 
      return @pin_obj.get_service("read_boolean").call()
    end
    dbus_method :read_analog, "out arg:s" do 
      return @pin_obj.get_service("read_analog").call()
    end      
    dbus_method :write_pwm, "in arg:s" do |arg|
      return @pin_obj.get_service("write_pwm").call(arg)
    end 
    def initialize (path_, pin_obj_)
      # DBus constructor
      super(path_)
      
      @pin_obj = pin_obj_
      end
  end
end
