#!/usr/bin/ruby 
require File.dirname(__FILE__) << "/LibComponent.rb"
require 'serialport'

# declaration de la description, des arguments et des I/O en mode 
# micro-optparse. permet de générer le --intropect et egalement de creer
# les objets

component = LibComponent::Component.new do |c|
  c.description  "The arduino drivers"
  c.default_name "arduino"
  c.option :Board , 'The kind of board: UNO, MEGA, NANO (default UNO)' , :default => "UNO"
  c.option :baup , 'The bauprate' , :default => 115200 
  c.option :port , 'The serial port', :default => "/dev/arduino"
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
  
  def quit
    @sp.close
  end

end

class Pin
 
  attr_accessor :arduino
  def initialize(name_,number_)
    @name = name_
    @number = number_
    @input = nil
    @arduino = nil
  end
  
end

module Pwm
  
  def write(value_,option_)
    if value_ > 255 
      value = 255
    else
      value = value_
    end
    
     Arduino.write("pwm #{@number} #{value}")
  end

end

#Read module and function definition

module Analog 
  
  def read(option_)
    return Arduino.write_and_read("adc #{@number}").to_f/1023
  end

end

module Dht11
  
  def read(option_)
    @sp.write("dht11 #{@number}")
    ret =  Arduino.read.split.reverse[0..1] # first value = temperature, seconde value hygro
    return [ret]
  end

end

module Digital
  
  def read(option_)
    if (@input == 0  or @input==nil)
       Arduino.write("pin #{@number} input") # if pin is set as output, set it as input
      @input = 1
    end
    return Arduino.write_and_read("pin #{@number} state")    
  end
  
  def write(value_,option_)
    if (@input==nil or @input == 1 )
      Arduino.write("pin #{@number} output") # if pin is set as output, set it as input
      puts "set out"
      @input = 0
    end
    if (value_.class==TrueClass or value_==1)
       Arduino.write("pin #{@number} 1")  
      return true
    end
    if (value_.class==FalseClass or value_==0)
       Arduino.write("pin #{@number} 0")  
      return true
    end
  end

end

module Common
  def push_arduino(ard_)
    @arduino = ard_
  end
  
  def push_pin_number(num_)
    @number = num_
  end

end
#
# Live
#

SERIAL_PORT = component.options[:port]
BAUPRATE = component.options[:baup]
BOARD = component.options[:Board]

# create a various number of pin according to the board
case BOARD

  when "UNO","NANO"
    NB_ANALOG_PIN = (0..5).to_a
    NB_DIGITAL_PIN = (0..13).to_a
    NB_PWM_PIN = [3,5,6,9,10,11]
    #Interupt , array of pin in order of interupt number
    INTERUPT_PIN = [2,3] # interupt number 0 1

  when "MEGA"
    NB_ANALOG_PIN = (0..15).to_a
    NB_DIGITAL_PIN = (0..53).to_a
    NB_PWM_PIN = (2..13).to_a
    #Interupt , array of pin in order of interupt number
    INTERUPT_PIN = [2,3,21,20,19,18] # interupt number 0 1 2 3 4 5
end

if !component.options[:introspect]
  Arduino = Serial_Arduino.new(SERIAL_PORT,BAUPRATE)
  component.on_quit do
    Arduino.quit
  end
end

NB_DIGITAL_PIN.each { |number|
  p = LibComponent::Input.new("/Digital#{number}","digital").extend(Digital,Common)
  p.push_pin_number(number)
  component << p
  
  p = LibComponent::Input.new("/Digital#{number}","dht11").extend(Dht11,Common)
  p.push_pin_number(number)
  component << p
}
NB_PWM_PIN.each { |number|
  p = LibComponent::Input.new("/Digital#{number}","pwm").extend(Pwm,Common)
  p.push_pin_number(number)
  component << p
}
NB_ANALOG_PIN.each { |number|
  p = LibComponent::Input.new("/Analog#{number}","analog").extend(Analog,Common)
  p.push_pin_number(number)
  component << p
}
component.run
