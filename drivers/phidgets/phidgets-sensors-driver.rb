#!/usr/bin/ruby
#
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


require 'dbus'


class PhidgetTemperatureSensor < DBus::Object

    dbus_interface "org.openplacos.driver.temperature" do

		dbus_method :read, "out return:v, in rawvalue:i, in option:a{sv}" do |rawvalue,option|
    	    (rawvalue * 0.22222) - 61.11
		end
	end
end

class PhidgetHumiditySensor < DBus::Object

    dbus_interface "org.openplacos.driver.humidity" do

		dbus_method :read, "out return:v, in rawvalue:i, in option:a{sv}" do |rawvalue,option|
    	    (rawvalue * 0.1906) - 40.2
		end
	end
end

class PhidgetLightSensor < DBus::Object

    dbus_interface "org.openplacos.driver.light" do

		dbus_method :read, "out return:v, in rawvalue:i, in option:a{sv}" do |rawvalue,option|
    	    (rawvalue)
		end
	end
end


# Bus Open and Service Name Request
bus = DBus.session_bus
service = bus.request_service("org.openplacos.drivers.phidgets.sensors")

drivers = Array.new
drivers << PhidgetTemperatureSensor.new( "/phidget/sensor/temperature" )
drivers << PhidgetHumiditySensor.new( "/phidget/sensor/humidity" )
drivers << PhidgetLightSensor.new( "/phidget/sensor/light" )

drivers.each do |driver|
    service.export(driver)
end

puts "listening"
main = DBus::Main.new
main << bus
main.run

