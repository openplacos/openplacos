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

require 'rubygems'
require 'barometer'
require 'openplacos'
require 'micro-optparse'

options = Parser.new do |p|
  p.banner = "driver for getting weather"
  p.version = "0.0.1"
  p.option :name, "the debus name", :default => "weather"
  p.option :location, "the city location, use ',' between multiples locations", :default => "Grenoble"
end.process!

$DEBUG = options[:debug]

#Write module and function definition

class Driver < DBus::Object

  dbus_interface "org.openplacos.driver" do
    dbus_method :quit do 
      Thread.new {
        sleep 2
        Process.exit(0)       
      }
    end  
  end
end


#Read module and function definition

module Module_read_analog 
  
  def read_analog(option_)
  barometer = Barometer.new(@location)
    case @type
      when "T" 
        return barometer.measure.current.temperature.c
      when "H" 
        return barometer.measure.current.humidity
      when "W" 
        return barometer.measure.current.wind.kph
    end
  end

end

module Other_common_fonctions
  def set_location(loc)
    @location = loc
  end
  
  def set_type(type)
    @type = type
  end
end
#
# Live
#
Barometer.config = { 1 => [:google] }

bus = DBus::system_bus
if(ENV['DEBUG_OPOS'] ) ## Stand for debug
  bus =  DBus::session_bus
end
service = bus.request_service("org.openplacos.drivers.#{options[:name].downcase}")

loc = options[:location].split(",")
Pin  = Array.new
loc.each { |l|
  
  Pin << Openplacos::Driver::GenericPin.new("/temperature_#{l}",[],["analog"])
  Pin.last.set_location(l)
  Pin.last.set_type("T")
  
  Pin << Openplacos::Driver::GenericPin.new("/humidity_#{l}",[],["analog"])
  Pin.last.set_location(l)
  Pin.last.set_type("H")
  
  Pin << Openplacos::Driver::GenericPin.new("/wind_#{l}",[],["analog"])
  Pin.last.set_location(l)
  Pin.last.set_type("W")
}
Pin.each { |pin|
  service.export(pin)
}

driver = Driver.new("Driver")
service.export(driver)

main = DBus::Main.new
main << bus
main.run
