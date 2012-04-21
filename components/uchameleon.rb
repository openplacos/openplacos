#!/usr/bin/ruby 
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"
require 'serialport'


# declaration of description, arguments and IO's with µ-optparse
# Allow to generate --introspect adequately

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "OpenplacOS driver for µChameleon board"
  c.default_name "uchameleon"
  c.option :baup , 'The bauprate' , :default => 115200 
  c.option :port , 'The serial port', :default => "/dev/ttyUSB0"
end


class Serial_uCham

  def initialize(port_,baup_)
    begin
      @sp = SerialPort.new port_, baup_
    rescue
      LibComponent::LibError.quit_server(10, "From µChameleon component: #{port_} did not opened correctly")
    end   
  end
  
  def write(string_)
    self.print_debug(string_)
    @sp.write(string_+ "\n")
  end
  
  def write_and_read(string_)
    write(string_)
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

  def quit
    @sp.close
  end

end


module Pwm

  def init
    @ucham.write("pwm #{@number} period 1000")
    @ucham.write("pwm #{@number} polarity 0")
    @ucham.write("pwm #{@number} on")
  end

  def exit
    @ucham.write("pwm #{@number} off")
 end 

  def write(value_,option_)
    value = value_ * 1000
    if value > 1000 
      value = 1000
    end
    value = value.to_i

    @ucham.write("pwm #{@number} width #{value}")
    return LibComponent::ACK
  end

end

#Read module and function definition

module Analog 
  
  def read(option_)
    return @ucham.write_and_read("adc #{@number}").to_f*(5.0/255.0)
  end

end

module Digital
  
  def read(option_)
    return @ucham.write_and_read("pin #{@number} state")    
  end
  
  def write(value_,option_)
    if (value_.class==TrueClass or value_==1)
      @ucham.write("pin #{@number} high")  
      return LibComponent::ACK
    end
    if (value_.class==FalseClass or value_==0)
      @ucham.write("pin #{@number} low")  
      return LibComponent::ACK
    end
    return LibComponent::Error  # Should never be there
  end

end

module Common
  def push_ucham_and_number(ucham_, num_)
    @ucham  = ucham_
    @number = num_
  end

  def set_input
    @ucham.write("pin #{@number} input") # if pin is set as output, set it as input
  end

  def set_output
    @ucham.write("pin #{@number} output") # if pin is set as output, set it as input 
  end  
end
#
# Live
#

SERIAL_PORT = component.options[:port]
BAUPRATE = component.options[:baup]
BOARD = component.options[:Board]

NB_DIGITAL_PIN = (1..18).to_a
NB_ANALOG_PIN  = (1..8).to_a
NB_PWM_PIN     = (9..12).to_a


if !component.options[:introspect]
  ucham = Serial_uCham.new(SERIAL_PORT,BAUPRATE)
  component.on_quit do
    ucham.quit
  end
end

NB_DIGITAL_PIN.each { |number|
  p = LibComponent::Input.new("/Pin#{number}","digital").extend(Digital,Common)
  p.push_ucham_and_number(ucham, number)
  component << p
}
NB_PWM_PIN.each { |number|
  p = LibComponent::Input.new("/Pin#{number}","pwm").extend(Pwm,Common)
  p.push_ucham_and_number(ucham, number)
  component << p
}
NB_ANALOG_PIN.each { |number|
  p = LibComponent::Input.new("/Pin#{number}","analog").extend(Analog,Common)
  p.push_ucham_and_number(ucham, number)
  component << p
}
component.run
