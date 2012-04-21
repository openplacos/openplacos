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
#    Grove temperature sensor component

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "grove temperature sensor"
  c.version "0.1"
  c.default_name "grovetemperature"
end

component << Raw = LibComponent::Output.new("/raw","analog","r")
component << C_temp = LibComponent::Input.new("/temperature","analog.sensor.temperature.celcuis")
component << F_temp = LibComponent::Input.new("/temperature","analog.sensor.temperature.farenheit")
component << K_temp = LibComponent::Input.new("/temperature","analog.sensor.temperature.kelvin")

Raw.buffer = 0.5

C_temp.on_read do |*args|
  a = Raw.read(*args)
  # From seeedstudio wiki http://www.seeedstudio.com/wiki/index.php?title=Project_Seven_-_Temperature
  
  resistance=(5/a-1)*10000; #TODO : retrieve thr alim voltage default to 5 v
  temperature=1/(Math.log(resistance/10000)/3975+1/298.15)-273.15;
  return temperature
end

F_temp.on_read do |*args|
  return 9.0/5.0*C_temp.read(*args) + 32 
end

K_temp.on_read do |*args|
  return C_temp.read(*args) + 273
end

component.run
