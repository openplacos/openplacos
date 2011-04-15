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
require "openplacos"
require "micro-optparse"

options = Parser.new(ARGV) do |p|
  p.banner = "This is openplacos plugins template"
  p.version = "template 1.0"
  p.option :option, "some options", :default => "nothing"
end.process!

opt = options[:option]

plugin = Openplacos::Plugin.new

plugin.opos.on_signal("create_measure") do |name,config|
  # do stuff when a measure is created
end

plugin.opos.on_signal("create_actuator") do |name,config|
  # do stuff when an actuator is created
end

plugin.opos.on_signal("new_measure") do |name, value, option|
  # do stuff when a measure is done
end

plugin.opos.on_signal("new_order") do |name, order, option|
  # do stuff when a order is send
end

plugin.run
