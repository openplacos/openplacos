#!/usr/bin/env ruby

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
#
#     Grove moisture sensor component
#     URL : http://seeedstudio.com/wiki/Grove_-_Moisture_Sensor

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "grove moisture sensor"
  c.version "0.1"
  c.default_name "grovemoisture"
  c.option :threshold, 'Threshold for digital output', :default => 2.5
end

component << Raw = LibComponent::Output.new("/raw","analog","r")
component << MoistAnalog = LibComponent::Input.new("/moisture","analog.sensor.moisture.volt")
component << MoistDigital = LibComponent::Input.new("/moisture","digital")

Raw.buffer = 0.5
Threshold = component.options[:threshold]

MoistAnalog.on_read do |*args|
  return Raw.read(*args)
end

MoistDigital.on_read do |*args|
  return Raw.read(*args) > Threshold
end

component.run
