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




require "#{File.expand_path(File.dirname(__FILE__))}/../libclient/lib/server.rb"


opos = LibClient::Server.new


def get_adjust(size_)
  if (size_ < 8)
    return "\t\t"
  end 
  if (size_ < 16)
    return "\t"
  end 
  return ""
end

def usage()

puts "Usage: "
puts "opos-client list              # Return sensor and actuator list and corresponding interface "
puts "opos-client get  <sensor>     # Make a read access on this sensor"
puts "opos-client set  <actuator>   # Make a write access on this actuator"
end


if (ARGV[0] == nil)
puts "Please specify an action"
usage()
Process.exit 1
end


if( ARGV[0] == "list")
  puts "Actuators\t"+ get_adjust("Actuators".length) +"   Interface"
  opos.actuators.each_pair{|key, value|
    adjust = get_adjust(key.to_str.length) # Cosmetic
    puts key +":\t" + adjust + "   "+ value.name.sub(/org.openplacos.server./, '')
  }
  puts "\nSensor\t"+ get_adjust("Sensor".length)+ "   Interface"
  opos.sensors.each_pair{|key, value|
    adjust = get_adjust(key.to_str.length)
     puts key +":\t" + adjust + "   "+ value.name.sub(/org.openplacos.server./, '')
  }
  
end # Eof 'list'

if( ARGV[0] == "set")
  if( ARGV.length < 3)
    puts "Please specify an actuator"
    usage()
    Process.exit 1
  end
  
  act_hash = Hash.new
  1.upto( ARGV.length - 2 ){ |i|
    if (opos.actuators[ARGV[i]] == nil)
      puts "No actuators called " + ARGV[i]
      Process.exit 1
    end
    act_hash.store(ARGV[i], opos.actuators[ARGV[i]])
  }

  if (ARGV[ARGV.length - 1].downcase == "on")
    act_hash.each_value { |act|
      act.on
    }
  else
    if (ARGV[ARGV.length - 1].downcase == "off")
      act_hash.each_value { |act|
        act.off
      }
    end
  end
end #Eof 'set'


if( ARGV[0] == "get")
  if( ARGV.length < 2)
    puts "Please specify a sensor"
    usage()
    Process.exit 1
  end
  
  sens_hash = Hash.new
  1.upto( ARGV.length - 1 ){ |i|
    if (opos.sensors[ARGV[i]] == nil)
      puts "No sensor called " + ARGV[i]
      Process.exit 1
    end
    sens_hash.store(ARGV[i], opos.sensors[ARGV[i]])
  }

  sens_hash.each_pair { |key, sens|
    puts key + ": " + sens.value[0].to_s
  }
   
end #Eof 'get'
