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
  attr_accessor :config, :objects, :service, :rooms , :measures, :actuators
  
  def initialize
    
    @bus = DBus::SessionBus.instance
    if @bus.service("org.openplacos.server").exists?
      @service = @bus.service("org.openplacos.server")
    
      @service.introspect
      @server_mutex = Mutex.new
      #discover all objects of server
      @objects = server_object_discover(@service)
      
      #get config from objects
      @config = get_config_from_objects(@objects)
      
      @rooms = service.root.keys
      @rooms.delete("Debug")
      @rooms.delete("server")
      
      #create measure and actuator pulling Thread
      @measures = Array.new
      @actuators = Array.new
      get_measure_list(@objects).each{ |meas|
        @measures.push Measure_Thread.new(@objects[meas]['org.openplacos.server.measure'],@server_mutex,1)
      }
      get_actuator_list(@objects).each{ |act|
        @actuators.push Actuator_Thread.new(@objects[act]['org.openplacos.server.actuator'],@server_mutex,1)
      }
      
      
    else
      puts "Can't find OpenplacOS server"
    end
    
  
  end  
  
  def get_objects(nod) #get objects from a node, ignore Debug objects
    obj = Hash.new
    nod.each_pair{ |key,value|
     if not(key=="Debug" or key=="server") #ignore debug objects
       if not value.object.nil?
        obj[value.object.path] = value.object
       else
        obj.merge!(get_objects(value))
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
      if not(obj["org.openplacos.server.config"]==nil)
        cfg[key] = obj["org.openplacos.server.config"].getConfig[0] 
      end
    }
    cfg
  end
  
  def get_measure_list(objects)
    measure = Array.new
    objects.each_key{ |key|
      if key.include?("Measure")
        measure.push(key)
      end
    }
    measure  
  end
  
  def get_actuator_list(objects)
    actuator = Array.new
    objects.each_key{ |key|
      if key.include?("Actuator")
        actuator.push(key)
      end
    }
    actuator 
  end



end

class Monitor < Gtk::Frame  #Minitor Widget

  def initialize(notebook,measure_th,actuator_th,measure_cfg)
    super('Monitor')
    
    @measures = measure_th
    @actuators = actuator_th

    @hbox = Gtk::HBox.new(true,6)
    
    #Create measure monitor frame
    meas_frame = Gtk::Frame.new("Measures")
    meas_box = Gtk::VBox.new(true,6)
    @measures.each{ |meas|
      meas_box.pack_start(Measure_Monitor.new(measure_cfg[meas.meas.object.path]),true)
    }
    meas_frame.add_child(Gtk::Builder.new,meas_box,nil)    
    
    #Create actuator monitor frame
    act_frame = Gtk::Frame.new("Actuators")
    act_box = Gtk::VBox.new(true,6)
    @actuators.each{ |act|
      act_box.pack_start(Gtk::Label.new(act.state.to_s),true)
    }
    act_frame.add_child(Gtk::Builder.new,act_box,nil)    
     
    
    @hbox.pack_start(meas_frame,true)
    @hbox.pack_start(act_frame,true)
    self.add_child(Gtk::Builder.new,@hbox,nil)    
    notebook.append_page(self,nil)

  end


end


class Measure_Thread < Thread
  attr_reader :value, :meas
  
  def initialize(meas,mutex,refresh_rate)
    @mutex = mutex
    @meas = meas
    @refresh_rate = refresh_rate
    @mutex.synchronize{@value = @meas.value[0]}
    super{
        loop do
          @mutex.synchronize{
            @value = @meas.value[0]
          }
          sleep @refresh_rate
        end
      }
  end

end

class Actuator_Thread < Thread
  attr_reader :state
  
  def initialize(act,mutex,refresh_rate)
    @mutex = mutex
    @act = act
    @refresh_rate = refresh_rate
    @mutex.synchronize{@state = @act.state[0]}
    super{
        loop do
          @mutex.synchronize{
            @state = @meas.state[0]
          }
          sleep @refresh_rate
        end
      }
  end

end

class Measure_Monitor < Gtk::Frame

  def initialize(config)
    super(config["name"])
    hbox = Gtk::HBox.new(true,6)
    
    #find image and push it into the container
    case config["unit"]
      when "Celsius"
        path = "./icons/leaf.png"
      when "%RH"
        path = "./icons/leaf.png"
      else 
        path = "./icons/leaf.png"
    end
    @image = Gtk::Image.new(path)
    hbox.pack_start(@image,true)
    
    # value label
    @value_label = Gtk::Label.new("")

     self.add_child(Gtk::Builder.new,hbox,nil)      
  end

end

