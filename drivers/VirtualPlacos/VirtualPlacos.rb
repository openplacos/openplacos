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
require 'pathname'

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
			if $notify==true 
				$notifyIface.Notify('VirtualPlacos', 0,Pathname.pwd.to_s + "/icones/VirtualPlacos.png","VirtualPlacos","Allumage de la ventillation",[], {}, -1)
			end
		else
			if state == false
				@ventilation = false
				if $notify==true 
					$notifyIface.Notify('VirtualPlacos', 0,Pathname.pwd.to_s + "/icones/VirtualPlacos.png","VirtualPlacos","Extinction de la ventillation",[], {}, -1)
				end
			end
		end
	end
	
	def setEclairage(state)
		if state == true
			@eclairage = true
			if $notify==true 
				$notifyIface.Notify('VirtualPlacos', 0,Pathname.pwd.to_s + "/icones/VirtualPlacos.png","VirtualPlacos","Allumage de l'eclairage",[], {}, -1)
			end
		else
			if state == false
				@eclairage = false
				if $notify==true 
					$notifyIface.Notify('VirtualPlacos', 0,Pathname.pwd.to_s + "/icones/VirtualPlacos.png","VirtualPlacos","Extinction de l'eclairage",[], {}, -1)
				end
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
	
	dbus_interface "org.openplacos.driver.analog" do
	
		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			return $placos.instance_variable_get("@"+@variable)
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
			$placos.method(@method).call value
			return "-1"
		end 
	
	end
	
	dbus_interface "org.openplacos.driver.digital" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			return $placos.instance_variable_get("@"+@variable)
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
			if (value.class==TrueClass) or (value.class==FalseClass)
				$placos.method(@method).call value
				return true
			else
				if (value==1)
					$placos.method(@method).call true
					return true				
				end
				if (value==0)
					$placos.method(@method).call false
					return true				
				end
				return false				
			end
		end 
			
	end 
	
	dbus_interface "org.openplacos.driver.signal" do
	
		dbus_signal :signal, "handle:i"
		
		dbus_method :activate, "out return:v, in activate:b,  in handler:i, in option:a{sv}" do |value, option|
			$placos.method(@method).call value
		end 
		
	end 

end


class Interupt < DBus::Object
		
	def initialize(variable,threshold)
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

end

if (ARGV[0] == nil)
  puts "Please specify a config file"
  puts "Usage: openplacos-server <config-file>"
  Process.exit
end

if (! File.exist?(ARGV[0]))
  puts "Config file " +ARGV[0]+" doesn't exist"
  Process.exit
end


if (! File.readable?(ARGV[0]))
  puts "Config file " +ARGV[0]+" not readable"
  Process.exit
end


#Load and parse config file
config =  YAML::load(File.read(ARGV[0]))

config_placos = config['placos']


#create placos
$placos = Virtualplacos.new(config_placos["Outdoor Temperature"].to_f,config_placos["Max Indoor Temperature"].to_f,config_placos["Outdoor Hygro"].to_f,config_placos["Light Time Constant"].to_f,config_placos["Ventillation Time Constant"].to_f,config_placos["Thread Refresh Rate"].to_f)


bus = DBus.session_bus

#check notification system
$notify = config['allow notify']

# Start notification systeme
if $notify==true
	notifyService = bus.service("org.freedesktop.Notifications")
	notifyObject = notifyService.object('/org/freedesktop/Notifications')
	notifyObject.introspect
	$notifyIface = notifyObject['org.freedesktop.Notifications']
end

#publish methods on dbus

service = bus.request_service("org.openplacos.drivers.virtualplacos")

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
	$interupt[index] = Interupt.new(cfg_interupt['variable'],cfg_interupt['threshold'])
}

main = DBus::Main.new
main << bus
main.run


