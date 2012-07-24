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
#     Grove light sensor component
#     URL : http://www.seeedstudio.com/wiki/Grove_-_Light_Sensor
#     Warning : Not tested yet

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "grove light sensor"
  c.version "0.1"
  c.default_name "grovelight"
end

component << Raw = LibComponent::Output.new("/raw","analog","r")
component << Luminance = LibComponent::Input.new("/light","analog.sensor.luminance.lux")
component << Resistance = LibComponent::Input.new("/light","analog.sensor.resistance.ohm")

Raw.buffer = 0.5

Resistance.on_read do |*args|
  a = Raw.read(*args)
  return (5.0 - a)*10.0/a 
end

Luminance.on_read do |*args|
  r = Resistance.read(*args)
  l0 = 10.0
  r0 = 15.0
  l = l0*((r/r0)**(-0.7))
  return l
end

component.run
