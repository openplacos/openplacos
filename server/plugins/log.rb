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

require "rubygems"
if (ENV["DEBUG_LIB"])
  require '../../gem/lib/openplacos/libplugin.rb'
else
  require "openplacos"
end


plugin = Openplacos::Plugin.new(__FILE__)


file = plugin.config['file']
if File.exists? file
  $log_file = File.open(file, "a+") 
else
  $log_file = File.new(file, "a+")
end

plugin.opos.on_signal("create_measure") do |name,config|
    date = Time.new.to_s
    $log_file.write date +":" + "Create measure "+"#{name} #{config.inspect}" + "\n"
    $log_file.flush 
end

plugin.opos.on_signal("create_actuator") do |name,config|
    date = Time.new.to_s
    $log_file.write date +":" + "Create actuator "+"#{name} #{config.inspect}" + "\n"
    $log_file.flush 
end

plugin.opos.on_signal("new_measure") do |name, value, option|
    date = Time.new.to_s
    val = value.to_s
    $log_file.write date +":" + "New measure "+"#{name} #{val}" + "\n"
    $log_file.flush 
end

plugin.opos.on_signal("new_order") do |name, order, option|
    date = Time.new.to_s
    ord = order.to_s
    $log_file.write date +":" + "New order "+"#{name} #{ord}" + "\n"
    $log_file.flush 
end

plugin.opos.on_signal("error") do |error, option|
    date = Time.new.to_s
    $log_file.write date +":" + error + "\n"
    $log_file.flush 
end

plugin.run
