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
#

require 'dbus'
require 'gtk2'

$INSTALL_PATH = '/usr/lib/ruby/openplacos/'
$LOAD_PATH << $INSTALL_PATH 

require 'client/libclient/lib/server.rb'

opos = LibClient::Server.new
Thread.abort_on_exception=true

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
      @meas = meas
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
    @act = act
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


windows = Gtk::Window.new
windows.signal_connect('destroy') { Gtk.main_quit }

notebook = Gtk::Notebook.new
notebook.set_tab_pos(Gtk::POS_TOP)

roomcontener = Hash.new
measure = Hash.new
actuator = Hash.new
server_acces = Mutex.new
config = opos.get_config_from_objects(opos.objects)

opos.rooms.each { |room|
  roomcontener[room] = Hash.new
  roomcontener[room]["Hbox"] = Gtk::HBox.new(true,6)
  opos.sensors.each{ |key,obj|
    roomcontener[room][key] = Gtk::Frame.new(key)
    test = Gtk::VBox.new(true,6)
    measure[key] = Measure.new(obj,config[key],server_acces)
    test.pack_start(measure[key],false)
    roomcontener[room][key].add_child(Gtk::Builder.new,test,nil)
    roomcontener[room]["Hbox"].pack_start(roomcontener[room][key],false)

  }
  
  opos.actuators.each{ |key,obj|
    roomcontener[room][key] = Gtk::Frame.new(key)
    test = Gtk::VBox.new(true,6)
    actuator[key] = Actuator.new(obj,config[key],server_acces)
    test.pack_start(actuator[key],false)
    roomcontener[room][key].add_child(Gtk::Builder.new,test,nil)
    roomcontener[room]["Hbox"].pack_start(roomcontener[room][key],false)
  }
  notebook.append_page( roomcontener[room]["Hbox"], Gtk::Label.new(room) )
}
windows.add(notebook)

windows.show_all

Gtk.main
