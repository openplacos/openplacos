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
#    HIH3610 humidity sensor component

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "HIH3610 humidity sensor"
  c.version "0.1"
  c.default_name "hih3610"
  c.option :valim , "the sensor alimentation voltage" , :default => 5.0
end

component << Raw = LibComponent::Output.new("/raw","analog","r")
component << Temperature = LibComponent::Output.new("/temperature","analog.sensor.temperature.celcuis","r")

component << Humidity = LibComponent::Input.new("/humidity","analog.sensor.humidity.rh")

Humidity.on_read do |*args|
  temperature = Temperature.read({})
  valim = component.options[:valim]
  sensorRH = (Raw.read({})/valim-0.16)/0.0062
  trueRH = (sensorRH)/(1.0546-0.00216*temperature)
  return trueRH
end

component.run
