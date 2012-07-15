#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "Wait for an event in pulling mode"
  c.version "0.1"
  c.default_name "waituntil"
  c.option :frequency, 'Default frequency', :default => 1
  c.option :threshold, 'Default threshold', :default => 0.0
  c.option :type , 'Kind of regulation (bool / boolinv / analog / analoginv)', :default => "bool"
#  c.frequency "Pulling frequency in second"
end

module SwitchModule

  def start
    @state = false
  end
  
  def set_options(options,sensor,actuator)
    @options = options
    @sensor = sensor
    @actuator = actuator
  end
  
  def read(option)
    return @state || false
  end

  def write(value,option)
    if value==1 or value==true
      @state = true
      @thread = Thread.new {
        while compare(@sensor.read({}),@options[:threshold]) do
          
          @actuator.write(true,option)
          sleep @options[:frequency]
        end
        @actuator.write(false,option)
        @state = false
      }
      return 0
    elsif value==0 or value==false
      @state = false
      if @thread.alive?
        @thread.kill
      end
      return @actuator.write(false,option)
    end
  end
  
  def compare(value,threshold)
    if @options[:type] == "bool"
      return value == threshold
    elsif @options[:type] == "boolinv"
      return value != threshold
    elsif @options[:type] == "analog"
      return value < threshold  
    elsif @options[:type] == "analoginv"
      return value > threshold  
    end
  end
end


if ["analog", "analoginv"].include?(component.options[:type])
  component << sensor   = LibComponent::Output.new("/sensor","analog")
else
  component << sensor   = LibComponent::Output.new("/sensor","digital")
end
component << actuator = LibComponent::Output.new("/actuator","digital")
component << switch   = LibComponent::Input.new("/switch","digital.order.switch").extend(SwitchModule)

switch.set_options(component.options,sensor,actuator)


component.run
