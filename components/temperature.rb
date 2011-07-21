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
require 'dbus-openplacos'
require "micro-optparse"
require 'yaml' 

Options = Parser.new do |p|
  p.banner = "This is openplacos component for a fake temperature"
  p.option :introspect, "introspect for openplacos n-third"
  p.option :name , "the name of the service", :default => "temperature"
end.process!(ARGV)


if (Options[:introspect])
  input_pins = {
    "/Temperature" => { "analog" => ["read"] }
  }

  input = {
    "pin" => input_pins
  }

  output_pins = {
    "/raw" => { "analog" => ["read"] }
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

class Temperature < DBus::Object

  dbus_interface "org.openplacos.analog" do
    dbus_method :read, "out return:v, in option:a{sv}" do |option|
      return OutputPorts["raw"]["org.openplacos.component.analog"].read(option)
    end
  end
  
end

class Ports < DBus::ProxyObject
  def initialize(name)
    super(Bus,"org.openplacos.server.internal","/#{Options[:name].downcase}/#{name}")
    self.introspect
  end
end

if(ENV['DEBUG_OPOS'] ) ## Stand for debug
  Bus = DBus::SessionBus.instance
  $INSTALL_PATH = File.dirname(__FILE__) + "/"
else
  Bus = DBus::SystemBus.instance
end

OutputPorts = Hash.new
InputPorts = Hash.new

OutputPorts["raw"] = Ports.new("raw")
InputPorts["Temperature"] = Temperature.new("Temperature")

service = Bus.request_service("org.openplacos.components.#{Options[:name].downcase}")

InputPorts.each_value do |input|
  service.export(input)
end

main = DBus::Main.new
main << Bus
main.run
