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


ENV["DBUS_THREADED_ACCESS"] = "1" #activate threaded dbus
require 'dbus-openplacos'

module Openplacos
  class Client # client for openplacos server 
    attr_accessor :config, :objects, :service, :sensors, :actuators, :rooms,  :reguls, :initial_room
    
    def initialize
      if(ENV['DEBUG_OPOS'] ) ## Stand for debug
        @bus =  DBus::SessionBus.instance
      else
        @bus =  DBus::SystemBus.instance
      end
      if @bus.service("org.openplacos.server").exists?
        @service = @bus.service("org.openplacos.server")
        @service.introspect
        #discover all objects of server
        @initial_room = Room.new(nil, "/")   
        @objects = get_node_objects(@service.root, @initial_room)
        @rooms = @initial_room.tree

        
        #get sensors and actuators
        @sensors = get_sensors
        @actuators = get_actuators
        @reguls = get_reguls
        
        @permissions = Hash.new
      else
        puts "Can't find OpenplacOS server"
        Process.exit 1
      end
      
      
    end  
    
    def get_node_objects(nod, father_) #get objects from a node, ignore Debug objects
      obj = Hash.new
      nod.each_pair{ |key,value|
        if not(key=="Debug" or key=="server" or key=="plugins" or key=="Authenticate") #ignore debug objects
          if not value.object.nil?
            obj[value.object.path] = value.object
            father_.push_object(value.object)
          else
            children = father_.push_child(key)
            obj.merge!(get_node_objects(value, children))
          end
        end
      }
      obj
    end
    
    def get_config_from_objects(objects) #contact config methods for all objects
      cfg = Hash.new
      objects.each_pair{ |key, obj|
        if not(obj["org.openplacos.server.config"]==nil)
          cfg[key] = obj["org.openplacos.server.config"].getConfig[0] 
        end
      }
      cfg
    end

    def get_objects
      return @objects
    end
    
    def get_iface_type(obj, det_)
      a = Array.new
      obj.interfaces.each { |iface|
        if(iface.include?(det_))
          a << iface
        end
      }
      a
    end

    def auth(login_,password_)
      authobj = @service.object("/Authenticate")["org.openplacos.authenticate"]
      ack,perm = authobj.authenticate(login_,password_)
      if ack==true
        if @permissions[login_].nil?
          @permissions[login_] = perm
        end
      end
      return ack
    end
    
    def readable?(path_,login_)
      return true if @permissions[login_]["read"].include?(path_)
      #check if one object is readable in the room
      @permissions[login_]["read"].each { |path|
        return true if path.include?(path_)
      }
      return false #else
    end
    
    def writeable?(path_,login_)
      return @permissions[login_]["write"].include?(path_)
    end
    
  end

  class Room
    attr_accessor :father, :childs, :path, :objects

    def initialize(father_, path_)
      @father = father_
      @path = path_
      @childs = Array.new
      @objects = Hash.new
    end

    def push_child (value_)
      children = Room.new(self, self.path  + value_ + "/")
      @childs << children
      return children
    end

    def push_object(obj_)
      @objects.store(obj_.path, obj_)
    end
    
    def tree()
      hash = Hash.new
      hash.store(@path, self)
      @childs.each { |child|
        hash.merge!(child.tree)
      }
      return hash
    end
    
  end
  
end
