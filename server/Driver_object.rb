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

Bus = DBus::SessionBus.instance


class Pin_object
  def initialize(id_, pin_obj_, interface_)
    
    # Class variables
    @id = id_
    @generical_services = Hash.new()
    pin_obj_.introspect 
    @proxy = pin_obj_[interface_]
  end

  def add_service(key_, value_)
    @generical_services.store(key_, value_)
  end

  def get_service(key_)
    return @proxy.method(@generical_services[key_])
  end

end

class Driver_object
  attr_reader :pins

  #1 
  #2 To find driver on dbus
  #3 To know if it is a card or a sensor
  def initialize(name_, path_dbus_, interface_, object_list_) # Constructor

    # Class variables
    @name = name_
    @path_dbus = path_dbus_
    @object_list = object_list_
    @interface = interface_
    

    # Open a Dbus socket
    @driver = Bus.service(@path_dbus)
    
    # Recognize standards objects
    @pins = Hash.new
    @object_list.each do |pin|
      pin_obj = Pin_object.new(pin, @driver.object(pin), @interface)
      @pins[pin]=pin_obj

      # Introspect
      doc = Document.new( @driver.object(pin).introspect)
      doc.root.each_element('//method name'){|interface|
        
        # Identify services by pattern matching
        # Get the value of attributes 'name' 
        y =  interface.attributes['name']
        
        service_name =  y.to_s
        if service_name.match(/Write_b/)
          @pins[pin].add_service("write_boolean",  service_name)
        end
        
        if  service_name.match(/Read_b/)
          @pins[pin].add_service("read_boolean",  service_name)
        end
        
        if  service_name.match(/Read_analog/)
          @pins[pin].add_service("read_analog",  service_name)
        end
        
        if  service_name.match(/Write_pwm/)
          @pins[pin].add_service("write_pwm",  service_name)
        end
        }
      
    end
  end
end




