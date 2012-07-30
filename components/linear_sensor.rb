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
#
#    Linear sensor. 
#    A file with measures sould be provided.
#    puts measures and corresponding true values in a CSV file like this :
#
#     measure1,truevalue1
#     measure2,truevalue2
#     measure3,truevalue3
#
#    At least 2 measures are required.


require File.dirname(__FILE__) << "/LibComponent.rb"
require 'csv'
require 'matrix'

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "linear sensor"
  c.category "Sensor"
  c.version "0.1"
  c.default_name "linearsensor"
  c.option :file , 'Measures file', :default => ""
  c.option :outiface , 'Output iface', :default => "analog.sensor"
  c.option :degree , 'Degree of regression', :default => 1
end

component << Raw = LibComponent::Output.new("/raw","analog","r")
component << Sensor = LibComponent::Input.new("/sensor",component.options[:outiface])

Raw.buffer = 0.5

x = Array.new
y = Array.new

def regression x, y, degree
  x_data = x.map {|xi| (0..degree).map{|pow| (xi**pow) }}
  mx = Matrix[*x_data]
  my = Matrix.column_vector y

  ((mx.t * mx).inv * mx.t * my).transpose.to_a[0].reverse
end

if File.exist?(component.options[:file])
  
  CSV.foreach(component.options[:file]) do |row|
    x << row[0].to_f
    y << row[1].to_f
  end
  alpha, beta = regression(x,y,component.options[:degree])
  
else
  alpha = 1
  beta = 0
end

Sensor.on_read do |*args|
  raw = Raw.read(*args)
  out = alpha*raw + beta
  return out
end


component.run
