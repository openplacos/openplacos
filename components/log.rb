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

require "rubygems"
require "../gem/lib/openplacos/libplugin.rb"
require "micro-optparse"
require 'yaml' 

options = Parser.new do |p|
  p.banner = "This is openplacos plugins for log file"
  p.version = "log 1.0"
  p.option :file, "file to log", :default => "/tmp/test.log"
  p.option :introspect, "introspect for openplacos n-third"
end.process!(ARGV)

if (options[:introspect])
  signal = Array.new
  signal.push("create_component")
  signal.push("new_measure")
  signal.push("new_request")
  input  = {
    "signal" => signal
  }
  config = {
    "input"  => input
  }

  puts config.to_yaml
  Process.exit(0)
end
plugin = Openplacos::Plugin.new

file = options[:file]

if File.exists? file
  log_file = File.open(file, "a+") 
else
  log_file = File.new(file, "a+")
end

plugin.opos.on_signal("create_component") do |name,config|
    date = Time.new.to_s
    log_file.write date +":" + "Create component "+"#{name} #{config.inspect}" + "\n"
    log_file.flush 
end

plugin.opos.on_signal("new_read") do |name, value, option|
    date = Time.new.to_s
    val = value.to_s
    log_file.write date +":" + "New measure "+"#{name} #{val}" + "\n"
    log_file.flush 
end

plugin.opos.on_signal("new_write") do |name, order, option|
    date = Time.new.to_s
    ord = order.to_s
    log_file.write date +":" + "New order "+"#{name} #{ord}" + "\n"
    log_file.flush 
end

plugin.opos.on_signal("error") do |error, option|
    date = Time.new.to_s
    log_file.write date +":" + error + "\n"
    log_file.flush 
end

plugin.run
