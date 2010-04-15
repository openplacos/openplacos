#!/usr/bin/ruby

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

class UchamAdcToVoltage < DBus::Object

	dbus_interface "org.openplacos.drivers.level1.uChamAdcToVoltage" do
    
    	dbus_method :convert, "in adc:i, out voltage:d" do |adc| 
			[(5.0/255)*adc]	
		end  
    
	end 
end


bus = DBus.session_bus
service = bus.request_service("org.openplacos.drivers.level1.uChamAdcToVoltage")

driver = UchamAdcToVoltage.new("uChamAdcToVoltage")
service.export(driver)

main = DBus::Main.new
main << bus
main.run
