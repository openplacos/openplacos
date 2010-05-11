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
#	 Virtual placos for tests

require 'dbus'
require 'thread'
require 'yaml' # Assumed in future examples

Thread.abort_on_exception = true

# Virtual placos class
class Virtualplacos 

	attr_accessor :inTemp, :eclairage, :ventilation, :outTemp, :outHygro, :inHygro, :inHygroSensor, :outHygroSensor

	def initialize(outTemp,maxInTemp,outHygro,constEclairage,constVentilation,th_refresh_rate)
		
		@outTemp = outTemp
		@maxInTemp = maxInTemp
		@inTemp = @outTemp
		
		@outHygro = outHygro
		@inHygro = outHygro
		
		@inHygroSensor = @inHygro + 0.1*@inTemp
		@outHygroSensor = @outHygro + 0.1*@outTemp
		
		@eclairage = false
		@ventilation = false
		@th_refresh_rate = th_refresh_rate
		
		@ConstEclairage = constEclairage
		@ConstVentilation = constVentilation
		
		@ventilation_thread = Thread.new{
			loop do
				sleep(@th_refresh_rate)
				if @ventilation == true
					@inTemp = @inTemp + (@outTemp - @inTemp)*(@th_refresh_rate/@ConstVentilation) # 1 order system
					@inHygro = @inHygro + (@outHygro - @inHygro)*(@th_refresh_rate/@ConstVentilation) # 1 order system
					@inHygroSensor = @inHygro + 0.1*@inTemp
				end					
			end
		}
		
		
		@eclairage_thread = Thread.new{
			loop do
				sleep(@th_refresh_rate)
				if @eclairage == true
					@inTemp = @inTemp + (@maxInTemp - @inTemp)*(@th_refresh_rate/@ConstEclairage) # 1 order system
					@inHygro = @inHygro + (95 - @inHygro)*(@th_refresh_rate/@ConstEclairage) # 1 order system
					@inHygroSensor = @inHygro + 0.1*@inTemp
				end
			end
		}
	
	end

	def setVentilation(state)
		if state == true
			@ventilation = true
		else
			if state == false
				@ventilation = false
			end
		end
	end
	
	def setEclairage(state)
		if state == true
			@eclairage = true
		else
			if state == false
				@eclairage = false
			end
		end
	end
	
	def dummy(state)
		puts("This is a dummy method")
	end

end


# Pin object,
#	- have a read method which return the attribute accessor of $placos defined by the name "variable"
#	- have a write method which execute the methode of $placos named "method"

class Pin < DBus::Object
		
	def initialize(dbusName,variable,method)
		super(dbusName)
		@variable = variable
		@method = method
	end
	
	dbus_interface "org.openplacos.drivers.DriverVirtualPlacos.methods" do
	
		dbus_method :Read_a, "out sortie:d" do  
			return $placos.instance_variable_get("@"+@variable)
		end  
		
		dbus_method :Read_b, "out sortie:b" do  
			return $placos.instance_variable_get("@"+@variable)
		end  
		
		dbus_method :Write_b, "in etat:b" do |etat|
			$placos.method(@method).call etat
		end 
		
		dbus_method :Write_pwm, "in etat:d" do |etat|
			$placos.method(@method).call etat
		end 
		
	end 

end

class Interupt < DBus::Object
		
	def initialize(dbusName,variable,threshold)
		super(dbusName)
		@variable = variable
		@threshold = threshold
		@state = false
		
		# Start pulling thread
		Thread.new{
			loop do
				sleep(0.1)
				
				if @state == false
				
					if $placos.instance_variable_get("@"+@variable) > @threshold
						#self.Signal(true)
						@state = true
					end
				
				elsif @state == true
				
					if $placos.instance_variable_get("@"+@variable) < @threshold
						#self.Signal(false)
						@state = false
					end
				
				end
			end
		}
		
	end
	
	dbus_interface "org.openplacos.drivers.DriverVirtualPlacos.signals" do
	
		dbus_signal :Signal, "state:b"
		
	end 

end


#Load and parse config file
config =  YAML::load(File.read('config.yaml'))

config_placos = config['placos']

#create placos
$placos = Virtualplacos.new(config_placos["Outdoor Temperature"].to_f,config_placos["Max Indoor Temperature"].to_f,config_placos["Outdoor Hygro"].to_f,config_placos["Light Time Constant"].to_f,config_placos["Ventillation Time Constant"].to_f,config_placos["Thread Refresh Rate"].to_f)


#publish methods on dbus
bus = DBus.session_bus
service = bus.request_service("org.openplacos.drivers.DriverVirtualPlacos")

#create pin objects
config_pins = config['pins']

$pin = Array.new

config_pins.each_with_index { |cfg_pin , index|
	$pin[index] = Pin.new(cfg_pin['dbusname'],cfg_pin['variable'],cfg_pin['method'])
	service.export($pin[index])
}

#create Interupt objects
config_interupts = config['interupts']

$interupt = Array.new

config_interupts.each_with_index { |cfg_interupt , index|
	$interupt[index] = Interupt.new(cfg_interupt['dbusname'],cfg_interupt['variable'],cfg_interupt['threshold'])
	service.export($interupt[index])
}


main = DBus::Main.new
main << bus
main.run


