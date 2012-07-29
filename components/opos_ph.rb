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
#     Openplacos pH sensor

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "openplacos pH sensor"
  c.category "Sensor"
  c.version "0.1"
  c.default_name "oposph"
  
end

component << Raw = LibComponent::Output.new("/raw","analog","r")
component << PH = LibComponent::Input.new("/ph","analog.sensor.ph")

Raw.buffer = 0.5

PH.on_read do |*args|
  
  raw = Raw.read(*args)
  ph = -4.6257*raw + 19.449
  return ph
end


component.run
