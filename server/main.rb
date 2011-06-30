#!/usr/bin/ruby -w

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

# $INSTALL_PATH = File.dirname(__FILE__) + "/"
 $INSTALL_PATH = '/usr/lib/ruby/openplacos/server/'
$LOAD_PATH << $INSTALL_PATH 
ENV["DBUS_THREADED_ACCESS"] = "1" #activate threaded dbus


# List of library include
require 'yaml' 
require 'rubygems'
require 'dbus-openplacos'
require 'micro-optparse'

# List of local include
#require 'Publish.rb'
require 'globals.rb'
require 'User.rb'
require 'Component.rb'

options = Parser.new do |p|
  p.banner = "The openplacos server"
  p.version = "0.0.1"
  p.option :file, "the config file", :default => "/etc/default/openplacos"
  p.option :debug, "activate the ruby debug flag"
end.process!

$DEBUG = options[:debug]

#DBus
if(ENV['DEBUG_OPOS'] ) ## Stand for debug
  Bus = DBus::SessionBus.instance
  $INSTALL_PATH = File.dirname(__FILE__) + "/"
else
  Bus = DBus::SystemBus.instance
end

service = Bus.request_service("org.openplacos.server")

#Global functions
$global = Global.new

class Top

  attr_reader :drivers, :objects, :plugins, :dbus_plugins, :users
  
  #1 Config file path
  #2 Dbus session reference
  def initialize (config_, service_)
    # Parse yaml
    @config           =  YAML::load(File.read(config_))
    @service          = service_
    @config_component = @config["objects"]

    # Hash of available dbus objects (measures, actuators..)
    # the hash key is the dbus path
    @components = Array.new
    @users      = Array.new

    @config_component.each do |component|
      @components << Component.new(component) # Create a component object
    end 
    
    @components.each  do |component|
      component.introspect   # Get informations from component -- threaded
    end

    @components.each  do |component|
      component.analyse   # Create pin objects according to introspect
    end

    @components.each  do |component|
      component.expose()   # Exposes on dbus interface service
      component.pins.each do |p|
        @service.export(p)
      end
    end
    

    temp_main = DBus::Main.new
    temp_main << @service.bus
   # temp_main_th = Thread.new { temp_main.run } # go for temporary dbus service

    @components.each  do |component|
      component.launch # Launch every component -- threaded
    end

    @components.each  do |component|
      # component.wait_for # verify component has been launched 
    end
    temp_main.run
 #   temp_main.quit
  end

end # End of Top

def quit(top_, main_)
  main_.quit
  Process.exit 0  
end

# Config file basic verification
file = options[:file]

if (! File.exist?(file))
  puts "Config file " +file+" doesn't exist"
  Process.exit 1
end


if (! File.readable?(file))
  puts "Config file " +file+" not readable"
  Process.exit 1
end

# Where am I ?
if File.symlink?(__FILE__)
  PATH =  File.dirname(File.readlink(__FILE__))
else 
  PATH = File.expand_path(File.dirname(__FILE__))
end

# Construct Top
top = Top.new(file, service)
main = DBus::Main.new
# quit the plugins when server quit

Signal.trap('TERM') do 
 quit(top, main)
end

Signal.trap('INT') do 
 quit(top, main)
end


# Let's Dbus have execution control

main << Bus
main.run

