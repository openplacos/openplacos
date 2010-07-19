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

require 'dbus'
require 'gtk2'

bus = DBus::SessionBus.instance
service = bus.service("org.openplacos.server")
service.introspect

class Measure < Gtk::Frame #Measure Widget
  attr_accessor :label_value
  
  def  initialize(meas,cfg,mutex)
      super(cfg["name"])
      @container = Gtk::Table.new(2,3)
      
      @label_name = Gtk::Label.new(cfg["name"])
      @label_value = Gtk::Label.new("nil")
      @label_unit = Gtk::Label.new(" " + cfg["informations"]["unit"])
      @curve = Gtk::Curve.new
      
      @curve.max_y= 30
      @curve.min_y= 20      
      @curve.curve_type = Gtk::Curve::TYPE_SPLINE
      @curve.modify_bg(Gtk::STATE_NORMAL,Gdk::Color.new(65535,65535,65535))
      @curve.modify_fg(Gtk::STATE_NORMAL,Gdk::Color.new(65535,0,0))   
        
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
          #puts "max : #{@meas_vect.sort.inspect}"
          @curve.set_range(0, @meas_vect.length , (@meas_vect.sort[0].to_i - 2), (@meas_vect.sort.reverse[0].to_i + 2) )

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

def get_objects(nod,obj) #get objects from a node, ignore Debug objects
  nod.each_pair{ |key,value|
   if not(key=="Debug") #ignore debug objects
     if not value.object.nil?
      obj[value.object.path] = value.object
     else
      get_objects(value,obj)
     end
   end
  }
  obj
end


def server_object_discover(service) #discover all objects for a given service
  node = service.root
  objects = Hash.new
  get_objects(node,objects)
end

def get_config_from_objects(objects) #contact config methods for all objects
  cfg = Hash.new
  objects.each_pair{ |key, obj|
    cfg[key] = obj["org.openplacos.server.config"].getConfig[0] 
  }
  cfg
end

objects =  server_object_discover(service)
config = get_config_from_objects(objects)

windows = Gtk::Window.new
windows.signal_connect('destroy') { Gtk.main_quit }

#room = Array.new

## find the diffents room from config
#config.each_value{ |val|

    #if val.has_key? "room"
      #if not room.include?(val["room"])
        #room.push(val["room"])
      #end
    #end
 
#}
##create Notebook 
#puts room.inspect

notebook = Gtk::Notebook.new
notebook.set_tab_pos(Gtk::POS_TOP)

node = service.root
roomcontener = Hash.new
measure = Hash.new
actuator = Hash.new
server_acces = Mutex.new

node.keys.each { |room|
  if not room=="Debug"
    roomcontener[room] = Hash.new
    roomcontener[room]["Hbox"] = Gtk::HBox.new(true,6)
    node[room].keys.each { |device|
      roomcontener[room][device] = Gtk::Frame.new(device)
      test = Gtk::VBox.new(true,6)
      node[room][device].keys.each { |obj|
        if device=="Measure"
          measure[obj] = Measure.new(objects[node[room][device][obj].object.path],config[node[room][device][obj].object.path],server_acces)
          test.pack_start(measure[obj],false)
        end
        if device=="Actuator"
          actuator[obj] = Actuator.new(objects[node[room][device][obj].object.path],config[node[room][device][obj].object.path],server_acces)
          test.pack_start(actuator[obj],false)
        end
      }
      roomcontener[room][device].add_child(Gtk::Builder.new,test,nil)
      roomcontener[room]["Hbox"].pack_start(roomcontener[room][device],false)
    }
    notebook.append_page( roomcontener[room]["Hbox"], Gtk::Label.new(room) )
  end
}




windows.add(notebook)

windows.show_all

Gtk.main
