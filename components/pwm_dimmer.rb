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
#    PWM dimmer

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "pwm dimmer"
  c.version "0.1"
  c.default_name "pwmdimmer"
end

component << Raw = LibComponent::Output.new("/raw","pwm","w")
component << Dimmer = LibComponent::Input.new("/dimmer","actuator.order.dimmer")
component << Switch = LibComponent::Input.new("/dimmer","actuator.order.switch")

State = 0

Dimmer.on_write do |value, option|
  if value<0
    State = 0
    return Raw.write(0,option)
  elsif value>1
    State = 1
    return Raw.write(1,option)
  else 
    State = value
    return Raw.write(value,option)
  end
end

Dimmer.on_read do |option|
  return 0 if State == false
  return 1 if State == true
  return State || 0
end

Switch.on_write do |value, option|
  if value==1 or value==true
    State = true
    return Raw.write(0,option)
  elsif value==0 or value==false
    State = false
    return Raw.write(1,option)
  end
end

Switch.on_read do |option|
  return true if State > 0
  return false if State == 0
  return State || false
end

component.run
