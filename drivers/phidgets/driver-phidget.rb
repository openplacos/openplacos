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
require 'rubygems'
require 'phidgets'
require 'yaml'

class InterfaceKitDigitalInput < DBus::Object

	def initialize(phidget, path, index)
	    super(path)
		@phidget, @index = phidget, index
	end

    dbus_interface "org.openplacos.driver.digital" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			begin
    			return value = @phidget.getInputState(@index)
			rescue
			    puts "Phidgets Error (#{e.code}). #{e}"
			    return -1
            end
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
		    puts "write not supported"
		    return -1
		end
	end
	  
end # class


class InterfaceKitDigitalOutput < DBus::Object

	def initialize(phidget, path, index)
	    super(path)
		@phidget, @index = phidget, index
	end

    dbus_interface "org.openplacos.driver.digital" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			begin
    			return value = @phidget.getOutputState(@index)
			rescue
			    puts "Phidgets Error (#{e.code}). #{e}"
			    return -1
            end
		end  
		
		dbus_method :write, "out return:v, in value:v" do |value, option|
            begin
    			value = @phidget.setOutputState(@index, value)
                puts "#{@path} = #{value}"
    			return 0
			rescue
			    puts "Phidgets Error (#{e.code}). #{e}"
			    return -1
            end
		end
	end
	
end # class


class InterfaceKitAnalogInput < DBus::Object

	def initialize(phidget, path, index)
	    super(path)
		@phidget, @index = phidget, index
	end

    dbus_interface "org.openplacos.driver.analog" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			begin
    			return value = @phidget.getSensorValue(@index)
			rescue
			    puts "Phidgets Error (#{e.code}). #{e}"
			    return -1
            end
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            puts "write not supported"
		    return -1
		end
	end  
	
end # class


module DBusInterfaceKit

    
end # module

class InterfaceKitDriver < DBus::Object

    def initialize( dbus_service )
    
        @service = dbus_service
        @pins = Hash.new
        @serial = ARGV[0]

        begin
            @phidget = Phidgets::InterfaceKit.new(@serial.to_i,2000)
        rescue Phidgets::Exception => e 
            puts "Phidgets Error (#{e.code}). #{e}"
            exit(-1)
        end

        # Instanciate DBUS-Objects
        @phidget.getInputCount.times do |index|
            path = "/interfacekit/#{@serial}/digital/input/#{index}"
            @pins[path] = InterfaceKitDigitalInput.new(@serial, path, index)
            @service.export(@pins[path])
            puts path
        end

        @phidget.getOutputCount.times do |index|
            path = "/interfacekit/#{@serial}/digital/output/#{index}"
            @pins[path] = InterfaceKitDigitalOutput.new(@serial, path, index)
            @service.export(@pins[path])
            puts path
        end

        @phidget.getSensorCount.times do |index|
            path = "/interfacekit/#{@serial}/analog/input/#{index}"
            @pins[path] = InterfaceKitAnalogInput.new(@serial, path, index)
            @service.export(@pins[path])
            puts path
        end
                
    end # def

end # class


#
# Live
#
if not ARGV[0]
    puts "Usage : #{$0} phidget-serial-number"
    exit(1)
end



# Bus Open and Service Name Request
bus = DBus.session_bus
phidget_dbus_service = bus.request_service("org.openplacos.drivers.phidgets.interfacekit#{ARGV[0]}")

driver = InterfaceKitDriver.new( phidget_dbus_service )

puts "listening"
main = DBus::Main.new
main << bus
main.run

