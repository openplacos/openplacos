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

plugin = Openplacos::Plugin.new

Dir.chdir(  File.expand_path(File.dirname(__FILE__) + "/")+ "/" + "rorplacos")

plugin.nonblock_run

## Inspirated from /usr/bin/rails

version = ">= 0"

gem 'rack', version

load Gem.bin_path('rack', 'rackup', version)

