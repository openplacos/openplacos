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

class Analog_pin < DBus::Object
  
    dbus_interface "org.openplacos.driver.analog" do
    
        dbus_method :read, "out return:v, in option:a{sv}" do |option|
            return self.read
        end  
      
    end
  
      
  def initialize(dbusName_,number_)
      super(dbusName_)
      @number = number_
  end

  def read
    return $sp.write_and_read("adc #{@number}").to_f/1023
  end
  
end
