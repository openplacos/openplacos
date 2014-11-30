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
  c.description  "A virtual pico brewery for testing purpose"
  c.version "0.1"
  c.ttl  0     # testing purpose
  c.default_name "virtualpico"
end


ROOM_temp = 25.0
Time_step = 0.1
Time_mult = 10

# a generic purpose kettle
class Kettle 
  attr_reader :volume, :temperature ,:density, :cp
  
  def initialize(vol_,temp_)
    @volume = vol_
    @temperature = temp_
    @density = 1.0
    @cp = 4185.0
    @rayon = 0.225
    @height = 0.45
    @surface = 2*Math::PI*@rayon*@height 
    @coeffdissipation = 10.0
  end
  
  def dilute(vol_,temp_,density_,cp_)
  
    if temp_>=@temperature
      v1 = vol_
      t1 = temp_
      d1 = density_
      cp1 = cp_
      
      v2 = @volume
      t2 = @temperature
      d2 = @density
      cp2 = @cp
    else
      v2 = vol_
      t2 = temp_
      d2 = density_
      cp2 = cp_
      
      v1 = @volume
      t1 = @temperature
      d1 = @density
      cp1 = @cp
    end
    
    # temperature of mixed fluid
    a = (v2*d2*cp2)/(v1*d1*cp1)
    @temperature = (a/(1.0+a))*t2 + t1/(1.0+a)
    
    # volume of mixed fluid
    @volume = v1 + v2
    
    # density of mixed fluid
    # http://solutionsguide.tetratec.com/index.asp?Page_ID=730&AQ_Magazine_Date=Current&AQ_Magazine_ID=2195
    @density = ( (d1 * v1) + (d2 * v2) ) / (v1 + v2)
    
    #heat capacity of mixed fluid
    m1 = v1*d1
    m2 = v2*d2
    @cp = ((m1*cp1) + (m2*cp2)) / (m1 + m2)
    
  end
  
  # fill the kettle with a given volume of fluid from a given kettle
  def fill(vol_,from_kettle_)
    dilute(vol_,from_kettle_.temperature,from_kettle_.density,from_kettle_.cp)
  end
  
  # empty the kettle of a given volume
  def empty(vol_)
    @volume = @volume - vol_
  end
  
  # heat the kettle with a given energy
  def heat(joules_)
    if @volume>0.0001
      dt = joules_/(@volume*@density*@cp)
      if (@temperature + dt > 100.0)
        # amount of energy to get 100°C
        dt = 100.0-@temperature
        e = dt*(@volume*@density*@cp)
        
        #vaporize the liquid with the resulting energy
        vaporize(joules_ - e)
      end
        
      @temperature += dt
    end
  end

  
  # vaporize a quantity of watter given an amount of energy
  def vaporize(joules_)
    m = joules_/(2260000)
    @volume -= m/@density
    if @volume < 0
      @volume = 0
    end
  end
  
  def dissipate(temp_,time_)
  
    # conduction entre l'air et la marmitte, par convection surface verticale 
    # on concidère la condicutivité thermique de l'acier comme suffisement bonne pour etre négligeable
    # http://fr.wikipedia.org/wiki/Coefficient_de_convection_thermique#Flux_thermique_.C3.A0_la_surface_de_la_paroi
    if @volume>0.0001
      dt = @temperature - temp_
      flux = ((@coeffdissipation*@surface))*dt
      @temperature -= (flux*time_)/(@volume*@density*@cp)
    end
  end
end


class Valve
  attr_accessor :status

  def initialize(inKet_,outKet_)
    @inputKet = inKet_ #kettle at the input of the valve
    @outKet = outKet_ #kettle at the output of the valve
    @status = false
  end
  
  def transfert(vol_)
    if @status
      if (@inputKet.volume - vol_)<=0
        vol_ = @inputKet.volume
      end
      
      @inputKet.empty(vol_)
      @outKet.fill(vol_,@inputKet)
    end
  end

end

class Heater
  attr_accessor :status
  
  def initialize(power_,kettle_)
    @power = power_
    @kettle = kettle_
    @status = 0.0
  end
 
  def heat(time_)
    joules = time_*@power*@status
    @kettle.heat(joules)
  end
  
end

module KettleTemp
  def push_kettle(kettle_)
    @kettle = kettle_
  end
  
  def read(*args)
    return @kettle.temperature
  end
  
end

module KettleVol
  def push_kettle(kettle_)
    @kettle = kettle_
  end
  
  def read(*args)
    return @kettle.volume
  end
  
end

module ValveOrder
  def push_valve(valve_)
    @valve = valve_
  end
  
  def read(*args)
    return @valve.status
  end
  
  def write(value_,option)
    @valve.status = value_
    return LibComponent::ACK
  end
  
end

module HeaterPwm

  def push_heater(heater_)
    @heater = heater_
  end
  
  def read(*args)
    return @heater.status
  end
  
  def write(value_,option)
    @heater.status = value_ if (value_>=0) and (value_ <= 1)
    @heater.status = 0 if value_<0
    @heater.status = 1 if value_>1
    return LibComponent::ACK
  end
end

kettles = Hash.new

kettles['HotLiquorTank'] = Kettle.new(0.0,ROOM_temp)
kettles['MashTun'] = Kettle.new(0.0,ROOM_temp)
kettles['BoilKettle'] = Kettle.new(0.0,ROOM_temp)

chauffe_eau = Kettle.new(200,60) #chauffeau eau 200L, 60°C
rims = Kettle.new(0,ROOM_temp) #Tube Rims

#create sensors
kettles.each do |key,value|
  #temperature sensor
  p = LibComponent::Input.new("/" + key + "/temperature","analog.sensor.temperature.celcuis").extend(KettleTemp)
  p.push_kettle(value)
  component << p

  #volume sensor
  p = LibComponent::Input.new("/" + key + "/volume","analog.sensor.volume.liter").extend(KettleVol)
  p.push_kettle(value)
  component << p    
  
end

#Rims (pas de volume)
p = LibComponent::Input.new("/Rims/temperature","analog.sensor.temperature.celcuis").extend(KettleTemp)
p.push_kettle(rims)
component << p


valves = Hash.new
valves['ChauffeEau_To_HotLiquorTank'] = Valve.new(chauffe_eau,kettles['HotLiquorTank']) # Rempli le HLT
valves['HotLiquorTank_To_MashTun'] = Valve.new(kettles['HotLiquorTank'],kettles['MashTun'])

valves.each do |key,value|
  #valve order
  p = LibComponent::Input.new("/" + key,"digital").extend(ValveOrder)
  p.push_valve(value)
  component << p  
end

heaters = Hash.new
heaters['HotLiquorTank'] = Heater.new(5500,kettles['HotLiquorTank'])
heaters['Rims'] = Heater.new(5500,rims)
heaters['BoilKettle'] = Heater.new(5500,kettles['BoilKettle'])

heaters.each do |key,value|
  #valve order
  p = LibComponent::Input.new("/" + key + "/Heater","pwm").extend(HeaterPwm)
  p.push_heater(value)
  component << p  
end

Thread.new do
  loop do
    sleep Time_step
    kettles.each do |key,value|
      value.dissipate(ROOM_temp,Time_step*Time_mult)
    end
    valves.each do |key,value|
      value.transfert(Time_step*Time_mult*10.0/60)
    end
    heaters.each do |key,value|
      value.heat(Time_step*Time_mult)
    end
    
  end
end

component.run
