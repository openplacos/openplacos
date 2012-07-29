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
#     Openplacos EC sensor

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "openplacos EC sensor"
  c.category "Sensor"
  c.version "0.1"
  c.default_name "oposec"
  
end

component << Freq = LibComponent::Output.new("/freq","analog.sensor.frequency.hertz","r")
component << Enable = LibComponent::Output.new("/enable","digital","w")
component << EC = LibComponent::Input.new("/ec","analog.sensor.ec.millisiemens")

Freq.buffer = 0.5

EC.on_read do |*args|
  Enable.write(true,{})
  freq = Freq.read(*args)
  Enable.write(false,{})
  return freq
end


component.run
