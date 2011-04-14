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
require "choice"

Choice.options do
    header ''
    header 'Specific options:'

    option :port do
      short '-p'
      long '--port=PORT'
      desc 'The port to listen on (default 3000)'
      cast Integer
      default 3000
    end
end

plugin = Openplacos::Plugin.new

Dir.chdir(  File.expand_path(File.dirname(__FILE__) + "/")+ "/" + "rorplacos")
plugin.nonblock_run


## Inspirated from /usr/bin/rails

version = ">= 0"

gem 'rails', version
ARGV.insert(0,"server")

load Gem.bin_path('rails', 'rails', version)

