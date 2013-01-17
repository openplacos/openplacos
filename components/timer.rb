#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "Wait for a period starting on falling edge of input"
  c.version "0.1"
  c.default_name "timer"
  c.option :period, 'Default period to wait in second', :default => 10

end

component << input  = LibComponent::Input.new( "/input","digital.order.switch")
component << output = LibComponent::Output.new("/output","digital")


input.on_write do |value, option|
  if value==1 or value==true
    @state = true
    return output.write(true,option)
  elsif value==0 or value==false
    @state = false
     @thread = Thread.new {
      sleep component.options[:period]
      output.write(false,option)
    }
    return LibComponent::ACK
  end
end

input.on_read do |option|
  return @state || false
end

component.run
