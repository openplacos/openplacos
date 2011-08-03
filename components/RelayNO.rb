#!/usr/bin/ruby 
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "This is openplacos component for a Normaly open Relay"
  c.version "0.1"
  c.default_name "relayno"
end

component << Raw = LibComponent::Output.new("/raw","digital","w")
component << Switch = LibComponent::Input.new("/switch","actuator.order.switch")

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
component.run
