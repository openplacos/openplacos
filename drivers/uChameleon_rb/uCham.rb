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
#

require '../libdriver/libdriver.rb'
require 'rubygems'
require 'serialport'
#Write module and function definition

module Module_write_analog 
  
  def write_analog(value_,option_)
    #No such function for uCham
  end

end

module Module_write_digital
  
  def write_digital(value_,option_)

    if (value_.class==TrueClass or value_==1)
      $sp.write("pin #{@number} high")  
      return true
    end
    if (value_.class==FalseClass or value_==0)
      $sp.write("pin #{@number} low")  
      return true
    end
    return false  # NOT recognized
  end

end

module Module_write_pwm
  
 def init_pwm
     $sp.write("pwm #{@number} period 1000")
     $sp.write("pwm #{@number} polarity 0")
     $sp.write("pwm #{@number} on")
  end

 def exit_pwm
    $sp.write("pwm #{@number} off")
 end

  def write_pwm(value_,option_)
    value = value_ * 1000
    if value > 1000 
      value = 1000
    end
    value = value.to_i

    $sp.write("pwm #{@number} width #{value}")
  end

end

#Read module and function definition

module Module_read_analog 
  
  def read_analog(option_)
    return $sp.write_and_read("adc #{@number}").to_f*(5.0/255.0)
  end

end

module Module_read_digital

 
  
  def read_digital(option_)
    if @input == 0 
      $sp.write("pin #{@number} input") # if pin is set as output, set it as input
      @input = 1
    end
    return $sp.write_and_read("pin #{@number} state")    
  end

end

module Other_common_fonctions
  
  def set_pin_number(number_)
    @number = number_
    @input = 1
  end

  def set_input
    $sp.write("pin #{@number} input") # if pin is set as output, set it as input
  end

  def set_output
    $sp.write("pin #{@number} output") # if pin is set as output, set it as input 
  end

end

class Serial_uCham

  def initialize(port_)
    @sp = SerialPort.new port_, 115200
  end
  
  def write(string_)
    self.print_debug(string_)
    @sp.write(string_+ "\n")
  end
  
  def write_and_read(string_)
    self.print_debug(string_)
    @sp.write(string_+ "\n")
    val = @sp.gets.split.reverse[0]
    self.print_debug("Return " + val)
    return val
  end

  def read
    return @sp.gets
  end
 
def print_debug(string_)
    if ENV['DEBUG_UCHAM']
      puts string_
    end    
  end

end



#
# Live
#

SERIAL_PORT = "/dev/ttyUSB0"
NB_ANALOG_PIN = (1..8).to_a
NB_PWM_PIN = (9..12).to_a
OTHERS_PIN = (13..18).to_a

bus = DBus.session_bus
service = bus.request_service("org.openplacos.drivers.uchameleon")

$sp = Serial_uCham.new(SERIAL_PORT)

analog_pin = Array.new
pwm_pin = Array.new
other_pin = Array.new

NB_ANALOG_PIN.each { |number|
  read_ifaces = ["analog", "digital"]
  write_ifaces = ["digital"]
  pin = GenericPin.new("/Pin_#{number}",write_ifaces,read_ifaces)
  analog_pin.push pin
  pin.set_pin_number(number)
  pin.write("digital", 0, nil)
  service.export(pin)
}

NB_PWM_PIN.each { |number|
  read_ifaces = ["digital"]
  write_ifaces = ["digital", "pwm"]
  pin = GenericPin.new("/Pin_#{number}",write_ifaces,read_ifaces)
  pwm_pin.push pin
  pin.set_pin_number(number)
  pin.write("digital", 0, nil)
  service.export(pin)
}

OTHERS_PIN.each { |number|
  read_ifaces = ["digital"]
  write_ifaces = ["digital"]
  pin = GenericPin.new("/Pin_#{number}",write_ifaces,read_ifaces)
  other_pin.push pin
  pin.set_pin_number(number)
  pin.write("digital", 0, nil)
  service.export(pin)
}



main = DBus::Main.new
main << bus
main.run
