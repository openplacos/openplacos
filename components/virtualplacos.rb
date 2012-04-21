#!/usr/bin/env ruby
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
#
#    Virtual placos for tests

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "A virtual placos for testing purpose"
  c.version "0.1"
  c.default_name "virtualplacos"
end

class Virtualplacos
  attr_accessor :fan , :light , :temperature , :hygrometry
  
  def initialize
    @fan = Fan.new
    @light = Light.new
    @thread = nil
    @temperature = 22.0
    @hygrometry = 35.0
  end
  
  def run
    @thread = Thread.new do 
      loop do
        @temperature = @temperature + (40 - @temperature)*0.01*@light.state + (22 - @temperature)*0.05*@fan.state
        @hygrometry  = @hygrometry +  (95 - @hygrometry )*0.01*@light.state + (35 - @hygrometry )*0.05*@fan.state
        sleep 0.2
      end
    end
  end
end


#class simulating a pwm Fan
class Fan
  attr_reader :state
  
  def initialize
    @state = 0
  end
  
  def on
    @state = 1
  end
  
  def off 
    @state = 0
  end
  
  def write(value_)
    @state = value_
  end
  
end

#class simulating a Light
class Light
  attr_reader :state
  
  def initialize
    @state = 0
  end
  
  def on
    @state = 1
  end
  
  def off 
    @state = 0
  end
end

#class simulating a LM335 temperature sensor for analog temperature
# return 2.73 V + 10mV/°C
class LM335
  def initialize(vp_)
    @vp = vp_
  end
  
  def read
    return 2.73 + 0.01*@vp.temperature
  end
end

# class simulating a HIH-3610 linear humidity sensor
# see http://content.honeywell.com/sensing/prodinfo/humiditymoisture/009012_2.pdf
# for voltage conversion and temperature compensation
class HIH3610
  def initialize(valim_,vp_)
    @vp = vp_
    @valim = valim_
  end
  
  def read
    trueRH = @vp.hygrometry
    sensorRH = (trueRH)*(1.0546-0.00216*@vp.temperature)
    return @valim*(0.0062*(sensorRH) + 0.16)
  end
end

module Fan_pwm
  def read(*args)
    return VP.fan.state
  end
  
  def write(value_,option)
    VP.fan.write(value_) if (value_>=0) and (value_ <= 1)
    VP.fan.write(0) if value_<0
    VP.fan.write(1) if value_>1
    return LibComponent::ACK
  end
end

module Fan_dig
  def read(*args)
    return true if VP.fan.state==1
    return false
  end
  
  def write(value_,option)
    if (value_== true) or (value_==1)
      VP.fan.on
    else
      VP.fan.off
    end
    return LibComponent::ACK
  end
end

VP = Virtualplacos.new
LM = LM335.new(VP)
HIH = HIH3610.new(5,VP)

#create sensors
component << S_Temp = LibComponent::Input.new("/temperature","analog.sensor.temperature.celcuis")
component << S_Hygro = LibComponent::Input.new("/hygrometry","analog.sensor.humidity.RH")
component << S_LM335 = LibComponent::Input.new("/Analog1","analog")
component << S_HIH = LibComponent::Input.new("/Analog2","analog")

#create Actuators
component << A_Fan_Pwm = LibComponent::Input.new("/Fan","pwm").extend(Fan_pwm)
component << A_Fan_Dig = LibComponent::Input.new("/Fan","digital").extend(Fan_dig)
component << A_Light = LibComponent::Input.new("/Light","digital")

S_Temp.on_read do |*args|
  return VP.temperature
end 

S_Hygro.on_read do |*args|
  return VP.hygrometry
end 

S_LM335.on_read do |*args|
  return LM.read
end

S_HIH.on_read do |*args|
  return HIH.read
end

A_Light.on_read do |*args|
  return VP.light.state
end

A_Light.on_write do |value_,options_|
  if (value_== true) or (value_==1)
    VP.light.on
  else
    VP.light.off
  end
  return LibComponent::ACK
end

VP.run
component.run
