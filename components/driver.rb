#!/usr/bin/ruby 
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

# declaration de la description, des arguments et des I/O en mode 
# micro-optparse. permet de générer le --intropect et egalement de creer
# les objets

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "This is openplacos component for a fake driver"
  c.version "0.1"
  c.default_name "driver"
end

module Input
  def read(*args)
    return 0.0
  end
  
  def write(*args)
    puts "youpi"
    return 1
  end
end

component << LibComponent::Input.new("/Pin_1","analog").extend(Input)

component.run
