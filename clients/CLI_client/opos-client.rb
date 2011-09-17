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


$LIB_PATH = File.expand_path(File.dirname(__FILE__)) + "/"
$LOAD_PATH << $LIB_PATH 


require "rubygems"
require 'scanf.rb'

#require File.expand_path(File.dirname(__FILE__)) + "/widget/modules.rb"
require "/home/flagos/projects/openplacos/gem/lib/openplacos/libclient.rb"



opos = Openplacos::Client.new


def get_adjust(string_len_, size_=2)
  if (string_len_ >= size_*8)
    return "" 
  end
  str = "\t"*(size_-(string_len_/8))
  return str
end

def usage()

puts "Usage: "
puts "list               # Return sensor and actuator list and corresponding interface "
puts "status             # Return a status of your placos"
puts "get  <object>      # Make a read access on this object"
puts "set  <object>    # Make a write access on this object"
# puts "regul <sensor>  <threshold>   \n   # Setup up a regul on this sensor with this threeshold"

end

def process(opos_, arg_)
if (arg_[0] == nil)
puts "Please specify an action"
usage()
return
end

objects = opos_.get_objects

if( arg_[0] == "list")
  puts "Actuators\t"+ get_adjust("Actuators".length) +"\t   Interface"
  opos_.actuators.each_pair{|key, value|
    adjust = get_adjust(key.to_str.length) # Cosmetic
    puts key +" :\t" + adjust + "   "+ value.name.sub(/org.openplacos.server./, '')
  }
  puts "\nSensor\t"+ get_adjust("Sensor".length)+ "\t   Interface" + "\t   Regul"
  opos_.sensors.each_pair{|key, value|
    adjust = get_adjust(key.to_str.length)    
    puts "#{key} :\t#{adjust}   #{value.name.sub(/org.openplacos.server./, '')}\t#{opos_.is_regul(value).to_s}"
  }
  return
end # Eof 'list'

if( arg_[0] == "status")
  objects.each_pair{ |key, obj|
    if (key != "/informations")
      puts "- " << key 
      obj.interfaces.each{ |iface|
        puts "\t\t#{iface} \t"<< obj[iface].render.to_s
      }
    end
  }
  return
end

if( arg_[0] == "set")
  if( arg_.length < 3)
    puts "Please specify an object"
    usage()
    return
  end
  
  req_hash = Hash.new
  if (objects[arg_[arg_.length-3]] == nil)
    puts "No actuators called " + arg_[arg_.length-3]
    return
  end
  req = objects[arg_[arg_.length-3]]
  puts req.class
  
  if(!req.interfaces.include?(arg_[arg_.length - 2]))
     puts "No interface called " << arg_[arg_.length - 2]
   end

  puts "SEND"
  req[arg_[arg_.length - 2]].write(arg_[arg_.length - 1], {})
  puts "OK"


  return
end #Eof 'set'


if( arg_[0] == "get")
  if( arg_.length < 2)
    puts "Please specify a sensor"
    usage()
    return
  end
  
  req_hash = Hash.new
  1.upto( arg_.length - 1 ){ |i|
    if (objects[arg_[i]] == nil)
      puts "No object called " + arg_[i]
      return
    end
    req_hash.store(arg_[i], objects[arg_[i]])    
  }

  req_hash.each_pair { |key, obj|
#    puts key + ": " + obj.value[0].to_s
    if (key != "/informations")
      puts "- " << key 
      obj.interfaces.each{ |iface|
        puts "\t\t" << obj[iface].render.to_s
      }   
    end
  }
  return
end #Eof 'get'

if( arg_[0] == "regul")
  if( arg_.length < 3)
    puts "Please specify a sensor"
    usage()
    return
  end
  
    if (opos_.reguls[arg_[1]] == nil)
      puts "No regul called " + arg_[1]
      return
    end
    regul = opos_.reguls[arg_[1]]

  if (arg_[2]=="disable" || arg_[2]=="off")
    regul.unset()
    puts arg_[1]+" disabled" 
    return
  end
  h = {"threshold"=>arg_[2]}
  puts h.inspect
  regul.set(h)
  puts "Set "+arg_[1]+" to "+arg_[2]
  return
end #Eof 'regul'


puts "Action not recognized"
usage()
end # process


loop do
  STDOUT.write "> "
  STDOUT.flush
  array = STDIN.gets.split(' ')
  if array[0] == "exit" || array[0] == "quit" 
      Process.exit 0 
  end
  process(opos, array)
end
