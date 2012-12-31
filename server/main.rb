#!/usr/bin/env ruby

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

$INSTALL_PATH = File.dirname(__FILE__) + "/"
$LOAD_PATH << $INSTALL_PATH
$INSTALL_PATH = '/usr/lib/ruby/openplacos/server/'
$LOAD_PATH << $INSTALL_PATH 
ENV["DBUS_THREADED_ACCESS"] = "1" #activate threaded dbus
SERVER_PATH = File.dirname(__FILE__) + "/"

# List of library include
require 'bundler/setup'
require 'json'
require 'yaml' 
require 'dbus-openplacos'
require 'micro-optparse'
require 'thin'
require 'sinatra/base'
require "active_record"
require "oauth2/provider"
require 'logger'
require 'haml'


# List of local include
require 'globals.rb'
require 'User.rb'
require 'Models.rb'
require 'Tracker.rb'
require 'Component.rb'
require 'Event_handler.rb'
require 'Dispatcher.rb'
require 'Export.rb'
require 'Info.rb'
require 'WebServer.rb'
require 'Top.rb'

options = Parser.new do |p|
  p.banner = "Openplacos server"
  p.version = "0.4"
  p.option :file   , "config file", :default => "/etc/default/openplacos"
  p.option :debug  , "activate the ruby-dbus debug flag"
  p.option :port, "port of webserver", :default => 4567
  p.option :log, "path to logfile", :default => "/tmp/opos.log"
  p.option :deamon, "run server as a deamon"
  p.option :pid_dir, "directory for pid file. PID file will be named openplacos.pid", :default => ""
end.process!

$DEBUG = options[:debug]

# log file
# monthly round-robin
log = Logger.new( options[:log], shift_age = 'monthly')

# create the webserver
pid_dir =  options[:pid_dir]
server = ThinServer.new('0.0.0.0', options[:port], pid_dir)

# deamonize if requested
# should be done before dbus
# deamonize fork the process so the pid is different
if options[:deamon]
  server.daemonize
end


#Database connexion
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "#{SERVER_PATH}/tmp/database.db", :pool => 25)
ActiveRecord::Base.logger = Logger.new("#{SERVER_PATH}/tmp/database.log")
ActiveRecord::Migrator.migrate("#{SERVER_PATH}db")


#DBus
InternalBus = DBus::ASessionBus.new

internalservice = InternalBus.request_service("org.openplacos.server.internal")
internalservice.threaded = true

def quit(top_, internalmain_,server_)
  top_.quit
  internalmain_.quit
  server_.stop!
end

# Config file basic verification
file = options[:file]

if (! File.exist?(file))
  Globals.error_before_start("Config file #{file} doesn't exist",log)
end


if (! File.readable?(file))
  Globals.error_before_start("Config file #{file} not readable",log)
end

# Where am I ?
if File.symlink?(__FILE__)
  PATH =  File.dirname(File.readlink(__FILE__))
else 
  PATH = File.expand_path(File.dirname(__FILE__))
end

Dispatcher.instance.init_dispatcher 

# Construct Top
top = Top.new(file, internalservice, log)
top.map
top.inspect_components
top.expose_component
top.create_exported_object
Dispatcher.instance.check_all_pin
top.update_exported_ifaces

internalmain = DBus::Main.new
internalmain << InternalBus
Thread.new { internalmain.run }

#launch components
top.launch_components

# quit the plugins when server quit
Signal.trap('TERM') do 
  quit(top, internalmain,server)
end

Signal.trap('INT') do 
  quit(top, internalmain,server)
end

if (top.debug_mode_activated)
  Globals.trace("At least one component is under debug, no tracker activated", Logger::WARN)
else
  tracker = Tracker.new(top,10)
  tracker.track
end
# start the WebServer
server.start

top.components.each { |c|
  if !c.thread.nil?
    c.thread.join
  end
}


