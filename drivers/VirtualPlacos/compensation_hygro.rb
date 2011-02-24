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
#	conversion driver for the hygro sensor of virtualplacos
# 	conversion are done through the read(option) method
#	option ==> Hash
#	"temp" ==> value of temperature
#	"hygro" ==> value of raw hygromety sensor 
#
#	reverse convertion can be done through the write(value,option) method
#	value = the already converted hygrometry value
#	option ==> Hash
#	"temp" ==> value of temperature

require 'dbus-openplacos'

class Conversion < DBus::Object

	dbus_interface "org.openplacos.driver.convert" do
		
		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			if (option["hygro"]==nil) or (option["temp"]==nil)
				return "hash needed {'temp' : temperature value , 'hygro' : hygrometry value}"
			else 
				return option["hygro"] - 0.1*option["temp"]
			end
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
			
			if (option["temp"]==nil)
				return "hash needed {'temp' : temperature value}"
			else 
				return value + 0.1*option["temp"]
			end
			
		end 
		
	end 
end


bus = DBus.session_bus
service = bus.request_service("org.openplacos.drivers.virtualplacos_hygrosensor")

driver = Conversion.new("convert")
service.export(driver)

main = DBus::Main.new
main << bus
main.run
