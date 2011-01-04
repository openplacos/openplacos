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




require "xmlrpc/client"

if ARGV.include?("-p")
  index = ARGV.index("-p")
  port = ARGV[ index + 1].to_i
  ARGV.delete_at(index)
  ARGV.delete_at(index)
else
  port = 8080
end

if ARGV.include?("-h")
  index = ARGV.index("-h")
  host = ARGV[ index + 1]
  ARGV.delete_at(index)
  ARGV.delete_at(index)
else
  host = "localhost"
end


opos = XMLRPC::Client.new( host, "/",port)

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
puts "opos-client list                      # Return sensor and actuator list and corresponding interface "
puts "opos-client get  <sensor>             # Make a read access on this sensor"
puts "opos-client set  <actuator> <method>  # Make a write access on this actuator"
puts "use -p <port> to set the port, default 8080"
puts "use -h <host> to set the host, default localhost"
end


if (ARGV[0] == nil)
puts "Please specify an action"
usage()
Process.exit 1
end


if( ARGV[0] == "list")
  puts "Actuators\t"+ get_adjust("Actuators".length) +"   Methods"
  acts = opos.call("actuators")
  acts.each{ |act|
    adjust = get_adjust(act.to_str.length)
    meths = opos.call("actuators.methods",act)
    act_m = "{ "
    meths.each{ |m| 
      act_m +=  "#{m} | " if m!="state"
    }
    puts act +":\t" + adjust + "   " + act_m + "}"
  }
  
  puts "\nSensor\t"+ get_adjust("Sensor".length)
  
  sens = opos.call("sensors")
  sens.each{ |sen|
    puts sen
  }
  
end # Eof 'list'

if( ARGV[0] == "set")
  if( ARGV.length < 3)
    puts "Please specify an actuator"
    usage()
    Process.exit 1
  end
  
  acts = Array.new
  act_list = opos.call("actuators")
  1.upto( ARGV.length - 2 ){ |i|
    if not act_list.include?(ARGV[i])
      puts "No actuators called " + ARGV[i]
      Process.exit 1
    end    
    acts.push(ARGV[i]) 
  }
  
  acts.each{ |a|
    meths = opos.call("actuators.methods",a)
    if not meths.include?(ARGV[ARGV.length - 1])
      puts "No methods #{ARGV[ARGV.length - 1]} for actuator #{a}"
      Process.exit 1
    end
    opos.call("set",a, ARGV[ARGV.length - 1])
  }
  
end #Eof 'set'


if( ARGV[0] == "get")
  if( ARGV.length < 2)
    puts "Please specify a sensor"
    usage()
    Process.exit 1
  end
  
  
  sens = Array.new
  sens_list = opos.call("sensors")
  1.upto( ARGV.length - 1 ){ |i|
    if not sens_list.include?(ARGV[i])
      puts "No sensors called " + ARGV[i]
      Process.exit 1
    end    
    sens.push(ARGV[i]) 
  }
  
  sens.each { |s|
    puts s + ": " + opos.call("get",s).to_s
  }
   
end #Eof 'get'
