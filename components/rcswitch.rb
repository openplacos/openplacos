#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "For PT2262 remote controled switch"
  c.version "0.1"
  c.default_name "rcswitch"
  c.option :adress , "the adress code for the 4 outlets" , :default => "00000" 
end

module Switch

  def set_code(adress_,number_)
    code =  [ "FFFFF", "0FFFF", "F0FFF", "FF0FF", "FFF0F", "FFFF0"]
    group = adress_.gsub("0","F").gsub("1","0")
    @ThreeStateCode = group << code[number_]    
  end
  
  def on
    return Transmitter.write("#{@ThreeStateCode}0F",{})
  end
  
  def off
    return Transmitter.write("#{@ThreeStateCode}F0",{})
  end
  
  def write(value, option)
    if value==1 or value==true
      @state = true
      return self.on
    elsif value==0 or value==false
      @state = false
      return self.off
    end
  end

  def read(options_)
    return @state || false
  end

end

component << Transmitter = LibComponent::Output.new("/transmitter","pt2262","w")
component << SwitchA = LibComponent::Input.new("/switchA","digital.order.switch").extend(Switch)
component << SwitchB = LibComponent::Input.new("/switchB","digital.order.switch").extend(Switch)
component << SwitchC = LibComponent::Input.new("/switchC","digital.order.switch").extend(Switch)
component << SwitchD = LibComponent::Input.new("/switchD","digital.order.switch").extend(Switch)

SwitchA.set_code(component.options[:adress].to_s,1)
SwitchB.set_code(component.options[:adress].to_s,2)
SwitchC.set_code(component.options[:adress].to_s,3)
SwitchD.set_code(component.options[:adress].to_s,4)

component.run
