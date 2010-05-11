#!/usr/bin/env ruby
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
#    Driver température pour capteur phidget
#   

require 'dbus'

class PhidgetTemperatureDriver < DBus::Object

    def initialize(path) 
    
        super(path)
    
        @driver = "org.openplacos.drivers.phidgets"
        @pin_path = "/org/openplacos/drivers/phidgets/xxx/analog/input/0"
        
        session_bus = DBus::SessionBus.instance
        # On va chercher le service concerné
        phidgets = session_bus.service(@driver)
        # Get the object from this service
        @pin = phidgets.object(@pin_path)
        
        @pin.introspect
        if not @pin.has_iface? "org.openplacos.drivers.api.analog"
            puts "Pin non compatible !"
            exit(1)
        end
        
    end

  # Create an interface aggregating all upcoming dbus_method defines.
  dbus_interface "org.openplacos.drivers.api" do
    dbus_method :read do 
        

    end

    dbus_signal :SomethingJustHappened, "toto:s, tutu:u"
  end

end

bus = DBus::SessionBus.instance
service = bus.request_service("org.openplacos.drivers.phidgets.temperature")
myobj = PhidgetTemperatureDriver.new("/org/openplacos/drivers/phidgets/temperature")
service.export(myobj)

puts "listening"
main = DBus::Main.new
main << bus
main.run

