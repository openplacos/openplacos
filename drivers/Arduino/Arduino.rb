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



require 'rubygems'
require 'serialport'
require 'openplacos'
require 'choice'
#Write module and function definition

Choice.options do
    header ''
    header 'Specific options:'

    option :name do
      short '-n'
      long '--name=NAME'
      desc 'The Name of the service (default arduino)'
      default "arduino"
    end
    
    option :port do
      short '-p'
      long '--port=PORT'
      desc 'The serial port (default /dev/arduino)'
      default "/dev/arduino"
    end
    
    option :baup do
      short '-b'
      long '--baup=BAUPRATE'
      desc 'The bauprate (default 115200)'
      cast Integer
      default 115200
    end
    
    option :Board do
      short '-B'
      long '--Board=UNO'
      desc 'The kind of board: UNO, MEGA, NANO (default UNO)'
      default "UNO"
    end
    
    option :remoteswpin do
      short '-r'
      long '--remoteswpin=NUMBER'
      desc 'The pin of the RF transmitter'
    end
    
    option :Remoteswadresslist do
      short '-R'
      long '--Remoteswadresslist=ADRESSLIST'
      desc 'A list of 5 bit adress of a group of pin, like "01100". diferent adresses are separated by semicolon ";"'
    end
end


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
    if @adress.nil? # not a remote switch
      if (value_.class==TrueClass or value_==1)
        $sp.write("pin #{@number} 1")  
        return true
      end
      if (value_.class==FalseClass or value_==0)
        $sp.write("pin #{@number} 0")  
        return true
      end
    else # it is a remote switch
      if (value_.class==TrueClass or value_==1)
        $sp.write("rcswitchon #{@number} #{@adress} #{@group}")  
        return true
      end
      if (value_.class==FalseClass or value_==0)
        $sp.write("rcswitchoff #{@number} #{@adress} #{@group}")  
        return true
      end
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

module Module_read_dht11
  
  def read_dht11(option_)
    $sp.write("dht11 #{@number}")
    ret = $sp.read.split.reverse[0..1] # first value = temperature, seconde value hygro
    return [ret]
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
  
  def set_remotesw_adress(adress_)
    @adress = adress_
  end
  
  def set_remotesw_group(group_)
    @group = group_
  end
end

class Serial_Arduino
  
  def initialize(port_,baup_)
    @sp = SerialPort.new port_, baup_
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

SERIAL_PORT = Choice.choices[:port]
BAUPRATE = Choice.choices[:baup]
BOARD = Choice.choices[:Board]

# create a various number of pin according to the board
case BOARD

  when "UNO","NANO"
    NB_ANALOG_PIN = (0..5).to_a
    NB_DIGITAL_PIN = (0..13).to_a
    NB_PWM_PIN = {3,5,6,9,10,11}
    #Interupt , array of pin in order of interupt number
    INTERUPT_PIN = {2,3} # interupt number 0 1

  when "MEGA"
    NB_ANALOG_PIN = (0..15).to_a
    NB_DIGITAL_PIN = (0..53).to_a
    NB_PWM_PIN = (2..13).to_a
    #Interupt , array of pin in order of interupt number
    INTERUPT_PIN = {2,3,21,20,19,18} # interupt number 0 1 2 3 4 5
end

$sp = Serial_Arduino.new(SERIAL_PORT,BAUPRATE)

bus = DBus::system_bus
if(ENV['DEBUG_OPOS'] ) ## Stand for debug
  bus =  DBus::session_bus
end
service = bus.request_service("org.openplacos.drivers.#{Choice.choices[:name].downcase}")

digital_pin = Array.new
analog_pin = Array.new

NB_DIGITAL_PIN.each { |number|
  write_ifaces = ["digital"]
  read_ifaces = ["digital","dht11"]
  if (NB_PWM_PIN).include?(number)
    write_ifaces.push "pwm"
    pin =  Openplacos::Driver::GenericPin.new("/Digital_Pin#{number}",write_ifaces,read_ifaces)
  else
    pin = Openplacos::Driver::GenericPin.new("/Digital_Pin#{number}",write_ifaces,read_ifaces)
  end
  digital_pin.push pin
  pin.set_remotesw_adress nil
  pin.set_pin_number(number)
  service.export(pin)
}

NB_ANALOG_PIN.each { |number|
  read_ifaces = ["analog"]
  write_ifaces = []
  pin = Openplacos::Driver::GenericPin.new("/Analog_Pin#{number}", write_ifaces, read_ifaces)
  analog_pin.push pin
  pin.set_pin_number(number)
  pin.set_remotesw_adress nil
  service.export(pin)
}
remoteswpin = Array.new
if not Choice.choices[:remoteswpin].nil?
  number = Choice.choices[:remoteswpin]
  write_ifaces = ["digital"]
  Choice.choices[:Remoteswadresslist].split(";").each { |adress|
    swA = Openplacos::Driver::GenericPin.new("/RemoteSw#{adress}A", write_ifaces, [])
    swA.set_remotesw_adress(adress)
    swA.set_remotesw_group(1)
    swA.set_pin_number(number)
    remoteswpin.push swA
    service.export(swA)
    
    swB = Openplacos::Driver::GenericPin.new("/RemoteSw#{adress}B", write_ifaces, [])
    swB.set_remotesw_adress(adress)
    swB.set_remotesw_group(2)
    swB.set_pin_number(number)
    remoteswpin.push swB
    service.export(swB)
    
    swC = Openplacos::Driver::GenericPin.new("/RemoteSw#{adress}C", write_ifaces, [])
    swC.set_remotesw_adress(adress)
    swC.set_remotesw_group(3)
    swC.set_pin_number(number)
    remoteswpin.push swC    
    service.export(swC)
    
    swD = Openplacos::Driver::GenericPin.new("/RemoteSw#{adress}D", write_ifaces, [])
    swD.set_remotesw_adress(adress)
    swD.set_remotesw_group(4)
    swD.set_pin_number(number)
    remoteswpin.push swD    
    service.export(swD)
  }
end
main = DBus::Main.new
main << bus
main.run
