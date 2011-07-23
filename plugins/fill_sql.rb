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

class Pulling_thread < Thread 
  def initialize(sensor_,frequency_)
    @sensor = sensor_
    @frequency = frequency_
    super {
      loop do
        begin
          @sensor.value
          sleep @frequency
        rescue
          puts "Error"
        end
      end
    }
  end
end

plugin = Openplacos::Plugin.new

sensor_list = Array.new

plugin.opos.on_signal("create_measure") do |name,config|
  if config["plugin_fill_sql_frequency"]
    sensor_list << { "path" => config["path"], "frequency" => config["plugin_fill_sql_frequency"].to_f}
  end
end

plugin.nonblock_run

client = Openplacos::Client.new

sensor_list.each do |s|
  sensor = client.sensors[s["path"]]
  frequency = s["frequency"]
  Pulling_thread.new(sensor,frequency)
end


