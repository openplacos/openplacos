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
#    Driver de sortie type pour un phidget
#   

require 'dbus'

class PhidgetOutputDriver < DBus::Object

    def initialize(path) 
    
        super(path)
    
        @driver = "org.openplacos.drivers.phidgets"
        @pin_path = "/org/openplacos/drivers/phidgets/77225/digital/output/0"
        
        session_bus = DBus::SessionBus.instance
        # On va chercher le service concerné
        phidgets = session_bus.service(@driver)
        # Get the object from this service
        @pin = phidgets.object(@pin_path)
        
        @pin.introspect
        @pin.default_iface = "org.openplacos.api.digital"
        
        if not @pin.has_iface? "org.openplacos.api.digital"
            puts "Pin non compatible !"
            exit(1)
        else
            puts "We have OpenplacOS api"
        end
    end
        

    # une méthode de test        
    dbus_interface "org.openplacos.drivers.one.output" do
     dbus_method :test_me do 
        (0..3).each do |i|
            @pin.write(i%2==0)
            puts "Pin0 : %s" % @pin.read
            sleep(1)
        end
     end
    end


  # Create an interface aggregating all upcoming dbus_method defines.
  dbus_interface "org.openplacos.drivers.api" do
    dbus_method :read, "out outstr:b" do
        # TODO : DBus exceptions 
        puts @pin.read
        @pin.read
    end

    dbus_signal :SomethingJustHappened, "toto:s, tutu:u"
    end

end

bus = DBus::SessionBus.instance
service = bus.request_service("org.openplacos.drivers.phidgets.output")
myobj = PhidgetOutputDriver.new("/org/openplacos/drivers/phidgets/output")
service.export(myobj)


puts "listening"
main = DBus::Main.new
main << bus
main.run

