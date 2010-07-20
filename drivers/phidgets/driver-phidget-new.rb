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


class InterfaceKitPin < DBus::Object

	def initialize(phidget, path, index)
	    super(path)
	    @phidget = phidget
		@index = index
	end

end # class


class IfkDigitalInput < InterfaceKitPin

    dbus_interface "org.openplacos.driver.digital" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			self.read
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
		    self.write value
		end
	end
	
	dbus_interface "org.openplacos.driver.signal" do
	    dbus_signal :change, "value:i" do
	        self.read
	    end
    end

    def read
        begin
            @phidget.synchronize do
                @phidget.getInputState(@index)
            end
		rescue
		    puts "InterfaceKit Error"
		    return -1
        end
    end
	
	def write(value)
	    puts "IfkDigitalInput : write not supported"
	    return -1
    end
	
end # class


class IfkDigitalOutput < InterfaceKitPin

    def initialize(phidget, path, index)
        super
        @state = false
    end #def

    dbus_interface "org.openplacos.driver.digital" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
            self.read
		end
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            self.write value
		end
	end
	
	def read
	    begin
            @phidget.synchronize do
        	    @state = @phidget.getOutputState(@index)
            end
		rescue
		    puts "InterfaceKit Error"
		    return -1
	    end
	end
	
	def write(value)
	    begin
	        @phidget.synchronize do
			    @phidget.setOutputState(@index, value)
		    end
		rescue
		    puts "Phidgets Error (#{e.code}). #{e}"
		    return -1
	    end
	end
	
end # class


class IfkAnalogInput < InterfaceKitPin

    dbus_interface "org.openplacos.driver.analog" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			self.read
		end
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            self.write value
		end
	end
		
	dbus_interface "org.openplacos.driver.signal" do
	    dbus_signal :change, "value:i"
    end
    
	def read
        begin
            @phidget.synchronize do
    			value = @phidget.getSensorValue(@index)
			end
		rescue
		    puts "Phidgets Error (#{e.code}). #{e}"
		    return -1
        end
	end

    def write(value)
        puts "IfkAnalogInput : write not supported"
	    return -1
    end	
	
end # class

# Redefine Phidgets::InterfaceKit to add mutex capabilities
class Phidgets::InterfaceKit

    def synchronize
        @mutex ||= Mutex.new
        @mutex.synchronize do
            yield
        end
    end
end # class

#
# Live
#
if __FILE__ == $0

    if not ARGV[0]
        puts "Usage : #{$0} address"
        exit(1)
    end

    # config
    PollingTime = 0.1
    address = ARGV[0].to_i
    
    # flags
    the_end = false

    # Bus Open and Service Name Request
    bus = DBus.session_bus
    dbus_service = bus.request_service("org.openplacos.drivers.interfacekit-#{address}")
    
    begin
        phidget = Phidgets::InterfaceKit.new(address,2000)
    rescue Phidgets::Exception => e 
        puts "Phidgets Error (#{e.code}). #{e}"
        exit(-1)
    end

    pins = Array.new
    phidget.getOutputCount.times do |i|
        path = "/interfacekit/#{address}/digital/output/#{i}"
        pins << IfkDigitalOutput.new(phidget, path, i)
    end
    phidget.getInputCount.times do |i|
        path = "/interfacekit/#{address}/digital/input/#{i}"
        pins << IfkDigitalInput.new(phidget, path, i)
    end
    phidget.getSensorCount.times do |i|
        path = "/interfacekit/#{address}/analog/input/#{i}"
        pins << IfkAnalogInput.new(phidget, path, i)
    end
    pins.each do |pin|
       dbus_service.export(pin)
       puts pin.path
    end

    # Polling thread
    thrd_poll = Thread.new do
        old = []
        until the_end
            new = []
            #puts "\e[H\e[2J"
            pins.each do |pin|
                new << pin.read
                # puts pin.path + ":" + pin.read.to_s
            end
            if new != old
                pins.each_index do |i|
                    if pins[i].class == IfkDigitalInput
                        pins[i].change(new[i]) if new[i] != old[i]
                    end
                end
            end
            old = new.dup
            sleep PollingTime
        end
    end

    puts "listening"
    main = DBus::Main.new
    main << bus
    main.run
    
    the_end = true
    thrd_poll.join
    
end
