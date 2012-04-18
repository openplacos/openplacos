#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"
require 'serialport'

# arg declaration -- Needed to generate --introspect phase

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "The arduino drivers"
  c.default_name "arduino"
  c.option :Board , 'The kind of board: UNO, MEGA, NANO (default UNO)' , :default => "UNO"
  c.option :baup , 'The bauprate' , :default => 115200 
  c.option :port , 'The serial port', :default => "/dev/arduino"
end

class Serial_Arduino
  
  def initialize(port_,baup_)
    begin
      @sp = SerialPort.new port_, baup_
    rescue
      LibComponent::LibError.quit_server(10, "From arduino component: #{port_} did not opened correctly")
    end
  end
  
  def write(string_)
    @sp.write(string_+ "\r\n")
  end
  
  def write_and_read(string_)
    write(string_)
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
    if 255*value_ > 255 
      value = 255
    else
      value = (value_*255).to_i
    end
    
     @arduino.write("pwm #{@number} #{value}")
  end

end

#Read module and function definition

module Analog 
  
  def read(option_)
    return @arduino.write_and_read("adc #{@number}").to_f/1023
  end

end

module Dht11
  
  def read(option_)
    @sp.write("dht11 #{@number}")
    ret =  @arduino.read.split.reverse[0..1] # first value = temperature, seconde value hygro
    return [ret]
  end

end

module Digital
  
  def read(option_)
    return @arduino.write_and_read("pin #{@number} state")    
  end
  
  def write(value_,option_)

    if (value_.class==TrueClass or value_==1)
       @arduino.write("pin #{@number} 1")  
      return true
    end
    if (value_.class==FalseClass or value_==0)
       @arduino.write("pin #{@number} 0")  
      return true
    end
  end

end

module Pt2262

  def write(value_,option_)
    @arduino.write("rcswitch #{@number} #{value_}")
    return true
  end

end

module Common
  def push_arduino_and_number(ard_, num_)
    @arduino = ard_
    @number = num_
  end

  def set_input
    @arduino.write("pin #{@number} input") # if pin is set as output, set it as input
  end

  def set_output
    @arduino.write("pin #{@number} output") # if pin is set as output, set it as input 
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
  arduino = Serial_Arduino.new(SERIAL_PORT,BAUPRATE)
  component.on_quit do
    arduino.quit
  end
end

NB_DIGITAL_PIN.each { |number|
  p = LibComponent::Input.new("/Digital#{number}","digital").extend(Digital,Common)
  p.push_arduino_and_number(arduino, number)
  component << p
  
  p = LibComponent::Input.new("/Digital#{number}","dht11").extend(Dht11,Common)
  p.push_arduino_and_number(arduino, number)
  component << p
  
  p = LibComponent::Input.new("/Digital#{number}","pt2262").extend(Pt2262,Common)
  p.push_arduino_and_number(arduino, number)
  component << p
}
NB_PWM_PIN.each { |number|
  p = LibComponent::Input.new("/Digital#{number}","pwm").extend(Pwm,Common)
  p.push_arduino_and_number(arduino, number)
  component << p
}
NB_ANALOG_PIN.each { |number|
  p = LibComponent::Input.new("/Analog#{number}","analog").extend(Analog,Common)
  p.push_arduino_and_number(arduino, number)
  component << p
}
component.run
