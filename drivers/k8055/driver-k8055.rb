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
require 'rubyk8055'
require 'thread'

include USB


class K8055Pin < DBus::Object

	def initialize(k8055, path, index)
	    super(path)
	    @k8055 = k8055
		@index = index
	end

end # class


class K8055DigitalInput < K8055Pin

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
            @k8055.synchronize do
                @k8055.get_digital @index
            end
		rescue
		    puts "K8055 Error"
		    return -1
        end
    end
	
	def write(value)
	    puts "K8055DigitalInput : write not supported"
	    return -1
    end
	
end # class


class K8055DigitalOutput < K8055Pin

    def initialize(k8055, path, index)
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
	    @state
	end
	
	def write(value)
	    begin
            @k8055.synchronize do
                @k8055.set_digital @index, value
                @state = value
            end
		rescue
		    puts "K8055 Error"
		    return -1
	    end
	end
	
end # class


class K8055AnalogInput < K8055Pin

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
		    @k8055.synchronize do
                @k8055.get_analog @index
            end
		rescue
		    puts "K8055 Error"
		    return -1
        end
	end

    def write(value)
        puts "K8055AnalogInput : write not supported"
	    return -1
    end	
	
end # class


class K8055AnalogOutput < K8055Pin

    def initialize(k8055, path, index)
        super
        @value = 0
    end #def

    dbus_interface "org.openplacos.driver.analog" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
           self.read
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            self.write value
		end
	end  
	
	def read
        @value
	end
	
	def write(value)
        begin
            @k8055.synchronize do
                @k8055.set_analog @index, value
                @value = value
            end
		rescue
		    puts "K8055 Error"
		    return -1
        end
	end
	
end # class

# Redifine the k8055 driver to include a mutex
class RubyK8055
    
    attr_accessor :mutex
  
    def synchronize
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
    dbus_service = bus.request_service("org.openplacos.drivers.k8055-#{address}")
    
    k8055 = RubyK8055.new
    begin
        k8055.connect address
    rescue
        puts "K8055 Error trying to connect"
        exit(-1)
    end
    # add mutex to driver
    k8055.mutex = Mutex.new
    # cleaning
    k8055.clear_all_digital
    k8055.clear_all_analog

    pins = Array.new
    (1..8).each do |i|
        path = "/digital/output/#{i}"
        pins << K8055DigitalOutput.new(k8055, path, i)
    end
    (1..5).each do |i|
        path = "/digital/input/#{i}"
        pins << K8055DigitalInput.new(k8055, path, i)
    end
    (1..2).each do |i|
        path = "/analog/output/#{i}"
        pins << K8055AnalogOutput.new(k8055, path, i)
    end
    (1..2).each do |i|
        path = "/analog/input/#{i}"
        pins << K8055AnalogInput.new(k8055, path, i)
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
            pins.each do |pin|
                new << pin.read
            end
            if new != old
                new.each_index do |i|
                    if pins[i].class == K8055DigitalInput
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
