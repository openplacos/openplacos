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
require 'rink'
require 'micro-optparse'

require File.expand_path(File.dirname(__FILE__)) + "/widget/modules.rb"
require File.dirname(__FILE__) + "/../../gem/lib/openplacos/libclient_oauth.rb"

options = Parser.new do |p|
  p.banner = "OpenplacOS CLI"
  p.option :session, "client bus on user session bus"
end.process!

if options[:session]
  ENV['DEBUG_OPOS'] = "1"
end

HOST="http://192.168.0.13:4567"


Opos = Openplacos::Client.new(HOST, "truc", ["read", "user"], "auth_code") # Beurk -- Constant acting as a global variable


class OpenplacOS_Console < Rink::Console
  command :help do 
    usage
  end

  command :usage do 
    usage
  end

  command :list do
    list
  end

  command :status do 
    status
  end

  command :get do |args|
    objects  = Opos.get_objects

    obj_name = args[0]
    if (!objects.include?(obj_name))
      puts "Object #{obj_name} does not exist"
      next # instead of return
    end
    obj      = objects[obj_name]

    iface    = "org.openplacos.#{args[1]}"
    if (!obj.has_iface?(iface))
      puts "Interface #{iface} does not exist"
      next
    end
    puts "- " <<  obj_name
    display(iface, obj[iface].render.to_s)
  end
 
  command :set  do |args|
    objects  = Opos.get_objects
    
    obj_name = args[0]
    if (!objects.include?(obj_name))
      puts "Object #{obj_name} does not exist"
      next # instead of return
    end
    obj      = objects[obj_name]

    iface    = "org.openplacos.#{args[1]}"
    if (!obj.has_iface?(iface))
      puts "Interface #{iface} does not exist"
      next
    end

    command = args
    command.delete_at(0)
    command.delete_at(0)
    obj[iface].set(command.join(" "))
    
  end




  def usage()

    puts "Usage: "
    puts "list                             # Return sensor and actuator list and corresponding interface "
    puts "status                           # Return a status of your placos"
    puts "get  <object>  <iface>           # Make a read access on this object"
    puts "set  <object>  <iface>  <value>  # Make a write access on this object"
    # puts "regul <sensor>  <threshold>   \n   # Setup up a regul on this sensor with this threeshold"

  end

  def status
    objects = Opos.get_objects
    objects.each_pair{ |key, obj|
      if (key != "/informations")
        puts "- " << key 
        obj.interfaces.each{ |iface|
          display(iface, obj[iface].render.to_s)
        }
      end
    }
  end

  def list
    objects = Opos.get_objects
    objects.each_pair{ |key, obj|
      if (key != "/informations")
        puts "- " << key 
        obj.interfaces.each{ |iface|
          display(iface, "")
        }
      end
    }
  end

  def display(iface_, value_)
    iface_short = iface_.sub("org.openplacos.", "")
    blank = ""
    printf "\t\t%s %#{50-iface_short.length}s \t%s\n", iface_short, blank, value_
  end

end

OpenplacOS_Console.new
