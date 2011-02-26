#/usr/bin/ruby

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

SERIAL_PORT = "/dev/ttyUSB1"
NB_ANALOG_PIN = 16
NB_DIGITAL_PIN = 54
NB_PWM_PIN = 2..13

#Interupt , array of pin in order of interupt number
INTERUPT_PIN = {2,3,21,20,19,18} # interupt number 0 1 2 3 4 5

require 'rubygems'
require 'serialport'
require 'dbus-openplacos'

require 'arduino_analog_pin.rb'
require 'arduino_digital_pin.rb'


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

$sp = Serial_Arduino.new(SERIAL_PORT)

bus = DBus::system_bus
if(ENV['DEBUG_OPOS'] ) ## Stand for debug
  bus =  DBus::session_bus
end
service = bus.request_service("org.openplacos.drivers.arduino")

digital_pin = Array.new
analog_pin = Array.new

NB_DIGITAL_PIN.times { |number|
  digital_pin.push Digital_pin.new("/Digital_Pin#{number}",number)
  if (NB_PWM_PIN.to_a).include?(number)
    puts number
    digital_pin[number].add_pwm_fonction
  end
  service.export(digital_pin[number])
}

NB_ANALOG_PIN.times { |number|
  analog_pin.push Analog_pin.new("/Analog_Pin#{number}",number)
  service.export(analog_pin[number])
}

main = DBus::Main.new
main << bus
main.run

