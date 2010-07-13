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
require 'rubyk8055'
require 'yaml'

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
			begin
                @k8055.get_digital @index
			rescue
			    puts "K8055 Error"
			    return -1
            end
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
		    puts "K8055DigitalInput : write not supported"
		    return -1
		end
	end
	  
end # class


class K8055DigitalOutput < K8055Pin

    def initialize(k8055, path, index)
        super
        @state = false
    end #def

    dbus_interface "org.openplacos.driver.digital" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
            @state
		end
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            begin
                @k8055.set_digital @index, value
                @state = value
			rescue
			    puts "K8055 Error"
			    return -1
            end
		end
	end
	
end # class


class K8055AnalogInput < K8055Pin

    dbus_interface "org.openplacos.driver.analog" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			begin
                @k8055.get_analog @index
			rescue
			    puts "K8055 Error"
			    return -1
            end
		end
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            puts "K8055AnalogInput : write not supported"
		    return -1
		end
	end
	
end # class


class K8055AnalogOutput < K8055Pin

    def initialize(k8055, path, index)
        super
        @value = 0
    end #def

    dbus_interface "org.openplacos.driver.analog" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
            @value
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            begin
                @k8055.set_analog @index, value
                @value = value
			rescue
			    puts "K8055 Error"
			    return -1
            end
		end
	end  
	
end # class


class K8055Driver < RubyK8055

    attr_reader :pins

    def initialize( dbus_service, address )

        super()
        @service = dbus_service
        @address = address.to_i
        @pins = Array.new

        # Instanciate DBUS-Objects
        (1..8).each do |i|
            path = "/k8055/#{@address}/digital/output/#{i}"
            @pins << K8055DigitalOutput.new(self, path, i)
        end
        (1..5).each do |i|
            path = "/k8055/#{@address}/digital/input/#{i}"
            @pins << K8055DigitalInput.new(self, path, i)
        end
        (1..2).each do |i|
            path = "/k8055/#{@address}/analog/output/#{i}"
            @pins << K8055AnalogOutput.new(self, path, i)
        end
        (1..2).each do |i|
            path = "/k8055/#{@address}/analog/input/#{i}"
            @pins << K8055AnalogInput.new(self, path, i)
        end
        @pins.each do |pin|
           @service.export(pin)
           puts pin.path
        end

	end # def

	def connect
	    super(@address)
	end # def

end # class


#
# Live
#
if __FILE__ == $0

    if not ARGV[0]
        puts "Usage : #{$0} address"
        exit(1)
    end

    # Bus Open and Service Name Request
    bus = DBus.session_bus
    k8055_dbus_service = bus.request_service("org.openplacos.drivers.k8055.id#{ARGV[0]}")
    k8055 = K8055Driver.new( k8055_dbus_service, ARGV[0] )
    begin
        k8055.connect
    rescue
        puts "K8055 Error trying to connect"
        exit(-1)
    end
    k8055.clear_all_digital
    k8055.clear_all_analog

    puts "listening"
    main = DBus::Main.new
    main << bus
    main.run
end
