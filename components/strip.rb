#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "1 input, N outputs"
  c.version "0.1"
  c.default_name "strip"
  c.option :number, 'Number of output', :default => 2

end

output = Array.new
component << input  = LibComponent::Input.new( "/input","digital.order.switch")
component.options[:number].times do |i|
  component << output[i] = LibComponent::Output.new("/output#{i}","digital")
end

input.on_write do |value, option|
  if value==1 or value==true
    @state = true
  elsif value==0 or value==false
    @state = false
  end
  output.each { |out|
    out.write(@state,option)
    sleep 0.2
  }
  return LibComponent::ACK
end


input.on_read do |option|
  return @state || false
end

component.run
