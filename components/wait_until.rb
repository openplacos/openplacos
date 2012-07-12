#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "Wait for an event in pulling mode"
  c.version "0.1"
  c.default_name "waituntil"
  c.option :frequency, 'Default frequency', :default => 1
  c.option :threshold, 'Default threshold', :default => 0
  c.option :type , 'Kind of regulation (bool / boolinv / analog / analoginv)', :default => "bool"
#  c.frequency "Pulling frequency in second"
end

component << Sensor   = LibComponent::Output.new("/sensor","digital")
component << Actuator = LibComponent::Output.new("/actuator","digital")
component << Switch   = LibComponent::Input.new("/switch","digital.order.switch")

Switch.on_startup do 
  @state = false
end

Switch.on_write do |value, option|
  if value==1 or value==true
    @state = true
    @thread = Thread.new {
      while Sensor.read({}) == 0 do
        Actuator.write(true,option)
        sleep component.options[:frequency]
      end
      Actuator.write(false,option)
      @state.false
    }
    return 0
  elsif value==0 or value==false
    @state = false
    if @thread.alive?
      @thread.kill
    end
    return Raw.write(false,option)
  end
end

Switch.on_read do |option|
  return @state || false
end

component.run
