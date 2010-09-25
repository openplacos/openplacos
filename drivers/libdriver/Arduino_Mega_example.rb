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

require 'libdriver.rb'
require 'rubygems'
require 'serialport'
#Write module and function definition

module Module_write_analog 
  
  def write_analog(value_,option_)
    #insert specific code
  end

end

module Module_write_digital
  
  def write_digital(value_,option_)
    if (@input==nil or @input == 1 )
      $sp.write("pin #{@number} output") # if pin is set as output, set it as input
      puts "set out"
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

end

module Module_write_pwm
  
  def write_pwm(value_,option_)
    if value_ > 255 
      value = 255
    else
      value = value_
    end
    
    $sp.write("pwm #{@number} #{value}")
  end

end

#Read module and function definition

module Module_read_analog 
  
  def read_analog(option_)
    return $sp.write_and_read("adc #{@number}").to_f/1023
  end

end

module Module_read_digital
  
  def read_digital(option_)
    if (@input == 0  or @input==nil)
      $sp.write("pin #{@number} input") # if pin is set as output, set it as input
      @input = 1
    end
    return $sp.write_and_read("pin #{@number} state")    
  end

end

module Module_read_pwm
  
  def read_pwm(option_)
    #insert specific code
  end

end

module Other_common_fonctions
  
  def set_pin_number(number_)
    @number = number_
  end

end

class Serial_Arduino
  
  def initialize(port_)
    @sp = SerialPort.new port_, 115200
  end
  
  def write(string_)
    @sp.write(string_+ "\r\n")
  end
  
  def write_and_read(string_)
    @sp.write(string_+ "\r\n")
    val = @sp.gets.split.reverse[0]
    return val
  end

  def read
    return @sp.gets
  end

end


#
# Live
#

SERIAL_PORT = "/dev/ttyUSB0"
NB_ANALOG_PIN = (0..15).to_a
NB_DIGITAL_PIN = (0..53).to_a
NB_PWM_PIN = (2..13).to_a

#Interupt , array of pin in order of interupt number
INTERUPT_PIN = {2,3,21,20,19,18} # interupt number 0 1 2 3 4 5

$sp = Serial_Arduino.new(SERIAL_PORT)

bus = DBus.session_bus
service = bus.request_service("org.openplacos.drivers.arduino")

digital_pin = Array.new
analog_pin = Array.new

NB_DIGITAL_PIN.each { |number|
  write_ifaces = ["digital"]
  read_ifaces = ["digital"]
  if (NB_PWM_PIN).include?(number)
    write_ifaces.push "pwm"
    pin =  GenericPin.new("/Digital_Pin#{number}",write_ifaces,read_ifaces)
  else
    pin = GenericPin.new("/Digital_Pin#{number}",write_ifaces,read_ifaces)
  end
  digital_pin.push pin
  pin.set_pin_number(number)
  service.export(pin)
}

NB_ANALOG_PIN.each { |number|
  read_ifaces = ["analog"]
  write_ifaces = []
  pin = GenericPin.new("/Analog_Pin#{number}", write_ifaces, read_ifaces)
  analog_pin.push pin
  pin.set_pin_number(number)
  service.export(pin)
}

main = DBus::Main.new
main << bus
main.run
