#!/usr/bin/ruby 
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "This is openplacos component for a Normaly open Relay"
  c.version "0.1"
  c.default_name "relayno"
end

component << Raw = LibComponent::Output.new("/raw","digital")
component << Switch = LibComponent::Input.new("/switch","actuator.order.switch")

Switch.on_write do |value, option|
  if value==1 or value==true
    return Raw.write(true,option)
  elsif value==0 or value==false
    return Raw.write(false,option)
  end
end

component.run
