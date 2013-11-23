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
#     PT100 temperature sensor

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "PT100 sensor"
  c.version "0.1"
  c.default_name "pt100"
  c.category "Sensor"
end

component << Raw = LibComponent::Output.new("/raw","analog","r")
component << C_temp = LibComponent::Input.new("/temperature","analog.sensor.temperature.celcuis")

Raw.buffer = 0.5

# PT100 constant
A = 3.9083e-3
B = -5.775e-7
Rnom = 100.0

# Amplifier constant
Vref = 5.02
R2 = 4.58e3
R3 = 4.57e3
R4 = 97.7
R5 = 9.86e3
R6 = 0.995e6

C_temp.on_read do |*args|
  a = Raw.read(*args) # read the raw value
  
  u = a/(1.0 + R6/R5) + Vref*(R4/(R3+R4)) #inverte the amplification chain
  resistance = u*R2/(Vref-u) - 0.5 # estimate the resistance of the PT100 an suppress measured wire resistance
  temperature = (- A +  Math.sqrt( A**2 - 4*B*(1-resistance/Rnom)))/(2*B) ## http://aviatechno.net/thermo/rtd03.php
  return temperature
end


component.run
