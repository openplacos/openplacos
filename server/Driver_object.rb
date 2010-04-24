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
  def initialize(id_, pin_obj)
    
    # Class variables
    @id = id_
    @generical_services = Array.new()
  end
end

class Driver_object

  #1 
  #2 To find driver on dbus
  #3 To know if it is a card or a sensor
  def initialize(name_, path_dbus_, driver_type_) # Constructor

    # Class variables
    @name = name_
    @path_dbus = path_dbus_
    @driver_type = driver_type_

    # Open a Dbus socket
    @driver = Bus.service(DRIVER)
    
    # Recognize standards objects
    @pins = Array.new
    OBJECT.each do |pin|
      puts pin.methods
      pin_obj = Pin_object.new(pin, @driver.object(pin))

      # Introspect
      doc = Document.new(pin_obj.introspect)
      doc.root.each_element('//method name'){|interface|

      # Identify services by pattern matching
        y =  interface.attributes

        # /!\                         This is dirty                     /!\ 
        # /!\ After parsing introspect, services name begin by "name".../!\ 
        service_name =  y.to_s.gsub(/^name/, "") # remove "name"
        puts service_name
        if service_name.match(/Write_b/)
          @pins[pin].generical_services['write_boolean'] = service_name
        end
        
        if  service_name.match(/read_b/)
          @pins[pin].generical_services['read_boolean'] =  service_name
        end
        
        if  service_name.match(/Read_analog/)
          @pins[pin].generical_services['read_analog'] =  service_name
        end
        
        if  service_name.match(/Write_pwm/)
          @pins[pin].generical_services['write_pwm'] =  service_name
        end
        }
      
    end
  end
end

#Configuration 

DRIVER = "org.openplacos.drivers.uChameleon"
OBJECT = ["/pin_1", "/pin_2","/pin_3", "/pin_4", "/pin_5", "/pin_6",  "/pin_7", "/pin_8", "/pin_9", "/pin_10",  "/pin_11", "/pin_12", "/pin_13", "/pin_14", "/pin_15", "/pin_16", "/pin_17"]
INTERFACE = "org.openplacos.driver.uChamInterface"
#METHODE = "Write_b"


driver = Driver_object.new "truc", "bidule", "chouette"




