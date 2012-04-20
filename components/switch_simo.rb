#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "This is openplacos component which has a single switch input and call multiple switch outputs"
  c.version "0.1"
  c.default_name "switchsimo"
  c.option :number, "number of outputs", :default => 2
end

Raw = Array.new

component.options[:number].times do |i|
  component << out = LibComponent::Output.new("/out#{i}","digital.order.switch","w")
  Raw << out
end
component << Switch = LibComponent::Input.new("/switch","digital.order.switch")

Switch.on_write do |value, option|
  if value==1 or value==true
    @state = true
    ret = Array.new
    Raw.each { |out|
      ret << out.write(true,option)
    }
    return 0 if ret.inject{|sum,x| sum + x }==0 # sum
    return 1 
  elsif value==0 or value==false
    @state = false
    ret = Array.new
    Raw.each { |out|
      ret << out.write(false,option)
    }
    return 0 if ret.inject{|sum,x| sum + x }==0
    return 1 
  end
end

Switch.on_read do |option|
  return @state || false
end

component.run
