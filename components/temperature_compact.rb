#!/usr/bin/ruby 
# -*- coding: utf-8 -*-


require File.dirname(__FILE__) << "/LibComponent.rb"

# declaration de la description, des arguments et des I/O en mode 
# micro-optparse. permet de générer le --intropect et egalement de creer
# les objets

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "This is openplacos component for a fake temperature"
  c.version "0.1"
  c.default_name "temperature"
end

component << Raw = LibComponent::Output.new("/raw","analog", component)
component << C_temp = LibComponent::Input.new("/temperature","sensor.temperature.celcuis", component)
component << F_temp = LibComponent::Input.new("/temperature","sensor.temperature.farenheit", component)

C_temp.on_read do |*args|
  return Raw.read(*args)
end

F_temp.on_read do |*args|
  return (C_temp.read(*args) - 32)/1.8
end

component.on_quit do
  puts "I quit !"
end

component.run
