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

class Digital_pin < DBus::Object
  
    dbus_interface "org.openplacos.driver.digital" do
    
        dbus_method :read, "out return:v, in option:a{sv}" do |option|
            return self.read
        end  

        dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            return self.write(value)
        end 
        
    end
  
      
  def initialize(dbusName_,number_)
      super(dbusName_)
      @input = 1
      $sp.write("pin #{@number} input")
      @number = number_
  end
  
  def read
    if @input == 0 
      $sp.write("pin #{@number} input") # if pin is set as output, set it as input
      @input = 1
    end
    return $sp.write_and_read("pin #{@number} state")    
  end
  
  def write(value_)
    if @input == 1
      $sp.write("pin #{@number} output") # if pin is set as output, set it as input
      @input = 0
    end    
    if (value_.class==TrueClass or value_==1)
      $sp.write("pin #{@number} 1")  
      return true
    end
    if (value_.class==FalseClass or value_==0)
      $sp.write("pin #{@number} 0")  
      return true
    end
  end
  
  def add_pwm_fonction
  
    dbusdef = 'dbus_interface "org.openplacos.driver.pwm" do
                  dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
                    return self.write_pwm(value)
                  end 
                end'
    self.singleton_class.instance_eval(dbusdef)
  end
  
  def write_pwm(value_)
    if value_ > 255 
      value = 255
    else
      value = value_
    end
    
    $sp.write("pwm #{@number} #{value}")
  end

end
