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


module LibClient
  class Server #openplacos server 
    attr_accessor :config, :objects, :service, :rooms , :sensors, :actuators
    
    def initialize
      
      @bus = DBus::SessionBus.instance
      if @bus.service("org.openplacos.server").exists?
        @service = @bus.service("org.openplacos.server")
      
        @service.introspect
        #@server_mutex = Mutex.new
        #discover all objects of server
        @objects = get_objects(@service.root)
        
        #get sensors and actuators
        @sensors = get_sensors
        @actuators = get_actuators
      else
        puts "Can't find OpenplacOS server"
        Process.exit 1
      end
      
    
    end  
    
    def get_objects(nod) #get objects from a node, ignore Debug objects
      obj = Hash.new
      nod.each_pair{ |key,value|
       if not(key=="Debug" or key=="server") #ignore debug objects
         if not value.object.nil?
          obj[value.object.path.split("/").reverse[0]] = value.object
         else
          obj.merge!(get_objects(value))
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
        if value.path.include?("Measure")
          sensors[key] = value['org.openplacos.server.measure']
        end
      }
      sensors  
    end
    
    def get_actuators
      actuators = Hash.new
      @objects.each_pair{ |key, value|
        if value.path.include?("Actuator")
          actuators[key] = value['org.openplacos.server.actuator']
        end
      }
      actuators
    end
  end
end
