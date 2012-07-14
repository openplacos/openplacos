#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "This is openplacos component for a Normaly open Relay"
  c.version "0.1"
  c.option :flow , "Flow in ml/mlin" , :default => 50.0
  c.default_name "pump"
end

component << Raw = LibComponent::Output.new("/raw","digital","w")
component << Switch = LibComponent::Input.new("/pump","digital.order.switch")
component << Dose = LibComponent::Input.new("/pump","analog.order.dose.ml")

Switch.on_write do |value, option|
  if value==1 or value==true
    @state = true
    return Raw.write(true,option)
  elsif value==0 or value==false
    @state = false
    return Raw.write(false,option)
  end
end

Switch.on_read do |option|
  return @state || false
end

Dose.on_read do |option|
  return @dose || 0
end

Dose.on_write do |value,option|
  
  if not @dosing
    @dosing = true
    @dose = value
    
    val = value.to_f
    Thread.new do 
      Switch.write(true,option)
      until @dose<0 do
        time = Time.now
        sleep 0.1
        @dose -= (Time.now-time)*component.options[:flow]/60.0
      end
      Switch.write(false,option)
      @dose = 0
      @dosing = false
    end
  end
  
  return 0
end

component.run
