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
require 'Qt4'


class Virtualplacos < DBus::Object

	attr_accessor :inTemp, :eclairage, :ventilation, :outTemp

	def initialize(outTemp,maxInTemp,constEclairage,constVentilation)
		
		@outTemp = outTemp
		@maxInTemp = maxInTemp
		@inTemp = @outTemp
		@eclairage = false
		@ventilation = false
		
		@ConstEclairage = constEclairage
		@ConstVentilation = constVentilation
		
		@ventilation_thread = Thread.new{
			loop do
				sleep(0.01)
				if @ventilation == true
					@inTemp = @inTemp + (@outTemp - @inTemp)*(0.01/@ConstVentilation) # 1 order system
				end					
			end
		}
		
		
		@eclairage_thread = Thread.new{
			loop do
				sleep(0.01)
				if @eclairage == true
					@inTemp = @inTemp + (@maxInTemp - @inTemp)*(0.01/@ConstEclairage) # 1 order system
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
	

end

class DriverVirtualPlacos < DBus::Object


	dbus_interface "org.openplacos.drivers.DriverVirtualPlacos.InTemperature" do
    
    	dbus_method :Read, "out sortie:d" do  
			[$placos.inTemp]
		end  
		
		dbus_method :Write, "in etat:b" do |etat|
			puts('salut')
		end 
		
	end 
	
	dbus_interface "org.openplacos.drivers.DriverVirtualPlacos.OutTemperature" do
    
    	dbus_method :Read, "out sortie:d" do  
			[$placos.outTemp]
		end  
		
		dbus_method :Write, "in etat:b" do |etat|
			puts('salut')
		end 
		
	end 
	
	dbus_interface "org.openplacos.drivers.DriverVirtualPlacos.Eclairage" do
    
    	dbus_method :Read, "out sortie:b" do  
			[$placos.eclairage]
		end  
		
		dbus_method :Write, "in etat:b" do |etat|
			$placos.setEclairage(etat)
		end 
		
	end 
	
	dbus_interface "org.openplacos.drivers.DriverVirtualPlacos.Ventilation" do
    
    	dbus_method :Read, "out sortie:b" do  
			[$placos.ventilation]
		end  
		
		dbus_method :Write, "in etat:b" do |etat|
			$placos.setVentilation(etat)
		end 
		
	end 

end




$placos = Virtualplacos.new(22,40,100,20)


bus = DBus.session_bus
service = bus.request_service("org.openplacos.drivers.DriverVirtualPlacos")

driver = DriverVirtualPlacos.new('VirtualPlacos')

service.export(driver)

main = DBus::Main.new
main << bus
main.run


