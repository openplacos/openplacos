#!/usr/bin/ruby 
# -*- coding: utf-8 -*-

#    This file is part of Openplacos.
#
#    Openplacos is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Openplacos is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Openplacos.  If not, see <http://www.gnu.org/licenses/>.
#

require "rubygems"
require "openplacos"
require "micro-optparse"
require 'yaml' 

options = Parser.new do |p|
  p.banner = "This is openplacos component for a fake temperature"
  p.option :introspect, "introspect for openplacos n-third"
end.process!(ARGV)


if (options[:introspect])
  input_pins = {
    "temperature" => { "analog" => ["read"] }
  }

  input = {
    "pin" => input_pins
  }

  output_pins = {
    "raw" => { "analog" => ["read"] }
  }
  
  output = {
    "pin" => output_pins
  }

  config = {
    "input"  => input,
    "output" => output
  }
  print config.to_yaml
  Process.exit 0
end

class Temperature < Dbus::Object

  def initialize(name)
    super(name)
  end

  dbus_interface "org.openplacos.analog" do
    dbus_method :read, "out return:v, in option:a{sv}" do |option|
      return Ports.raw["analog"].read
    end
  end
