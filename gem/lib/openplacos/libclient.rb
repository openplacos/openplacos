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
        @objects = get_objects(@service.root, @initial_room)
        @rooms = @initial_room.tree

        
        #get sensors and actuators
        @sensors = get_sensors
        @actuators = get_actuators
        @reguls = get_reguls
      else
        puts "Can't find OpenplacOS server"
        Process.exit 1
      end
      
    
    end  
    
    def get_objects(nod, father_) #get objects from a node, ignore Debug objects
      obj = Hash.new
      nod.each_pair{ |key,value|
       if not(key=="Debug" or key=="server") #ignore debug objects
         if not value.object.nil?
           obj[value.object.path] = value.object
           father_.push_object(value.object)
         else
           children = father_.push_child(key)
           obj.merge!(get_objects(value, children))
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
    
    def get_sensors
      sensors = Hash.new
      @objects.each_pair{ |key, value|
        if value.has_iface?('org.openplacos.server.measure')
          sensors[key] = value['org.openplacos.server.measure']
        end
      }
      sensors  
    end
    
    def is_regul(sensor)
      # get dbus object of sensor
      key = get_sensors.index(sensor)
      if (key == nil)
        return false
      end

      # Test interface
      if (@objects[key].has_iface?('org.openplacos.server.regul'))
        return true
      else
        return false
      end
    end

    def get_regul_iface(sensor)
      if (is_regul(sensor)==nil)
        return nil
      end
      key = get_sensors.index(sensor)
      return @objects[key]['org.openplacos.server.regul']
    end

    def get_actuators
      actuators = Hash.new
      @objects.each_pair{ |key, value|
        if value.has_iface?('org.openplacos.server.actuator')
          actuators[key] = value['org.openplacos.server.actuator']
        end
      }
      actuators
    end
    
    def get_reguls
      reguls = Hash.new
      @objects.each_pair{ |key, value|
        if value.has_iface?('org.openplacos.server.regul')
          reguls[key] = value['org.openplacos.server.regul']
        end
      }
      reguls
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
