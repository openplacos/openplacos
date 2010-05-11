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
#	convert int value from µCham ADC's to voltage level

require 'dbus'

class Conversion < DBus::Object

	dbus_interface "org.openplacos.drivers.level1.convert" do
    
    	dbus_method :convert, "in temperature:d, in hygroSensor:d, out hygro:d" do |temperature, hygroSensor| 
			return hygroSensor - 0.1*temperature
		end  
    
	end 
end


bus = DBus.session_bus
service = bus.request_service("org.openplacos.drivers.level1.Hygro")

driver = Conversion.new("org/openplacos/drivers/level1/Convert")
service.export(driver)

main = DBus::Main.new
main << bus
main.run
