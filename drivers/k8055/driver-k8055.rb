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


class K8055DigitalInput < DBus::Object

	def initialize(k8055, path, index)
	    super(path)
		@board, @index = k8055, index
	end

    dbus_interface "org.openplacos.driver.digital" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			begin
    			return value = @board.get_digital( @index )
			rescue
			    puts "K8055 Error (#{e.code}). #{e}"
			    return -1
            end
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
		    puts "write not supported"
		    return -1
		end
	end
	  
end # class


class K8055DigitalOutput < DBus::Object

	def initialize(k8055, path, index)
	    super(path)
		@board, @index = k8055, index
		@state = false
	end

    dbus_interface "org.openplacos.driver.digital" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			begin
    			return @state
			rescue
			    puts "K8055 Error (#{e.code}). #{e}"
			    return -1
            end
		end  
		
		dbus_method :write, "out return:v, in value:v" do |value, option|
            begin
    			value = @board.set_digital @index, value
    			if value 
    			    @state = true
			    else
			        @state = false
		        end
                puts "#{@path} = #{value}"
    			return 0
			rescue
			    puts "K8055 Error (#{e.code}). #{e}"
			    return -1
            end
		end
	end
	
end # class



class K8055AnalogInput < DBus::Object

	def initialize(k8055, path, index)
	    super(path)
		@board, @index = k8055, index
	end

    dbus_interface "org.openplacos.driver.analog" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
			begin
    			return value = @board.get_analog( @index)
			rescue
			    puts "K8055 Error (#{e.code}). #{e}"
			    return -1
            end
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            puts "write not supported"
		    return -1
		end
	end  
	
end # class


class K8055AnalogOutput < DBus::Object

	def initialize(k8055, path, index)
	    super(path)
		@board, @index = k8055, index
	end

    dbus_interface "org.openplacos.driver.analog" do

		dbus_method :read, "out return:v, in option:a{sv}" do |option|
            puts "read not supported"
		end  
		
		dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
            begin
    			value = @board.set_analog @index, value
    			return true
			rescue
			    puts "K8055 Error (#{e.code}). #{e}"
			    return -1
            end
		end
	end  
	
end # class


