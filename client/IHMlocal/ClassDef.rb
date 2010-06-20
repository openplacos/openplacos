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

class Room < Gtk::HBox
  
  def initialize
    super(true,6)
    
  end

end


class Measure < Gtk::Frame #Measure Widget
  attr_accessor :label_value
  
  def  initialize(meas,cfg,mutex)
      super(cfg["name"])
      @container = Gtk::Table.new(2,3)
      
      @label_name = Gtk::Label.new(cfg["name"])
      @label_value = Gtk::Label.new("nil")
      @label_unit = Gtk::Label.new(" " + cfg["informations"]["unit"])
      @curve = Gtk::Curve.new
      
      @container.attach(Gtk::Label.new(""),0,1,0,1,Gtk::EXPAND,Gtk::SHRINK)
      @container.attach(@label_value,1,2,0,1,Gtk::SHRINK,Gtk::SHRINK)
      @container.attach(@label_unit,2,3,0,1,Gtk::SHRINK,Gtk::SHRINK)
      @container.attach(@curve,0,3,1,2,Gtk::FILL)
      
      @mutex = mutex
      @meas = meas['org.openplacos.server.measure']
      @meas_vect = Array.new
      @th = Thread.new{
        loop do
          sleep 1
          @mutex.synchronize{
            val = @meas.value[0]
            @label_value.text = val.to_s[0..3]
            @meas_vect.push(val)
          }
          if @meas_vect.length > 60*10
            @meas_vect.shift
          end
          @curve.set_vector(@meas_vect.length,@meas_vect)
          
        end
      }
        self.add_child(Gtk::Builder.new,@container,nil)
  end
end

class Actuator < Gtk::Frame #actuator Widget
  def initialize(act,cfg,mutex)
    super(cfg["name"])
    
    @container = Gtk::HBox.new(true,6)
    @act = act['org.openplacos.server.actuator']
    @mutex = mutex
    @button = Hash.new
    
    @act.methods.each_key{ |key|
      if not key=="state"
        @button[key] = Gtk::Button.new(key)
        @container.pack_start(@button[key],true)
        @button[key].signal_connect('clicked'){
          @mutex.synchronize{ @act.method(key).call }
        }
      end
    }
    
    self.add_child(Gtk::Builder.new,@container,nil)
  end
end


class Server #openplacos server 
  attr_accessor :config, :objects, :service, :rooms
  
  def initialize
    
    @bus = DBus::SessionBus.instance
    if @bus.service("org.openplacos.server").exists?
      @service = @bus.service("org.openplacos.server")
    
      @service.introspect
    
      #discover all objects of server
      @objects = server_object_discover(@service)
      
      #get config from objects
      @config = get_config_from_objects(@objects)
      
      @rooms = service.root.keys
      @rooms.delete("Debug")
    else
      puts "Can't find OpenplacOS server"
    end
    
  
  end  
  
  def get_objects(nod) #get objects from a node, ignore Debug objects
    obj = Hash.new
    nod.each_pair{ |key,value|
     if not(key=="Debug") #ignore debug objects
       if not value.object.nil?
        obj[value.object.path] = value.object
       else
        get_objects(value)
       end
     end
    }
    obj
  end


  def server_object_discover(service) #discover all objects for a given service
    node = service.root
    objects = get_objects(node)
  end

  def get_config_from_objects(objects) #contact config methods for all objects
    cfg = Hash.new
    objects.each_pair{ |key, obj|
      cfg[key] = obj["org.openplacos.server.config"].getConfig[0] 
    }
    cfg
  end



end

class Monitor < Gtk::Frame  #Minitor Widget

  def initialize(notebook)
    super('Monitor')
    
    @hbox = Gtk::HBox.new(true,6)
    
    notebook.append_page(self,nil)

  end


end
