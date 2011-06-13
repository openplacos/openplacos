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
require "micro-optparse"
require 'digest/sha1'

options = Parser.new do |p|
  p.banner = "This script generate a string of config for an user"
  p.version = "0.0.1"
  p.option :name, "The name of the user", :default => ""
  p.option :group, "The group of the user", :default => ""
end.process!


if options[:name]==""
  puts "Enter an username"
  STDOUT.write "> "
  STDOUT.flush
  options[:name] = STDIN.gets.chomp
end

puts "Enter a password for user #{options[:name]}"
STDOUT.write "> "
STDOUT.flush
system "stty -echo"
password = STDIN.gets.chomp
system "stty echo"
hash = Digest::SHA1.hexdigest(password<<"_openplacos")

puts "\nEnter read permissions"
puts "  [1] all"
puts "  [2] measures"
puts "  [3] actuators"
STDOUT.write "> "
STDOUT.flush
readperm = STDIN.gets.chomp.to_i

readperm = case readperm
              when 1 then "all"
              when 2 then "measures"
              when 3 then "actuators"
              else "all"
end

puts "\nEnter write permissions"
puts "  [1] all"
puts "  [2] measures"
puts "  [3] actuators"
STDOUT.write "> "
STDOUT.flush
writeperm = STDIN.gets.chomp.to_i

writeperm = case writeperm
              when 1 then "all"
              when 2 then "measures"
              when 3 then "actuators"
              else "all"
end

output =  "- login: #{options[:name]}\n"
output << "  hash: '#{hash}'\n"
output << "  permissions:\n"
output << "    read: #{readperm}\n"
output << "    write: #{writeperm}\n"

puts "Paste the following result in your openplacos config file :\n\n"

puts output

