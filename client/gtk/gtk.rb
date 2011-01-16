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
require 'rubygems'
require 'openplacos'
require 'gtk2'

module OposGtk

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

end

## main 

opos = Openplacos::Client.new

windows = Gtk::Window.new
windows.signal_connect('destroy') { Gtk.main_quit }


notebook = Gtk::Notebook.new
notebook.set_tab_pos(Gtk::POS_TOP)

measure = Hash.new
actuator = Hash.new
server_acces = Mutex.new

box = mesbox = Gtk::HBox.new(true,6)

mesbox = Gtk::VBox.new(true,6)

opos.sensors.each_pair do |path,sensor|
   
        measure[path] = OposGtk::Measure.new(sensor,opos.objects[path]["org.openplacos.server.config"].getConfig[0] ,server_acces)
        mesbox.pack_start(measure[path],false)
end

box.pack_start(mesbox,false)

actbox = Gtk::VBox.new(true,6)

opos.actuators.each_pair do |path,act|

        actuator[path] = OposGtk::Actuator.new(act,opos.objects[path]["org.openplacos.server.config"].getConfig[0],server_acces)
        actbox.pack_start(actuator[path],false)
end
box.pack_start(actbox,false)

notebook.append_page( box, Gtk::Label.new("test") )

windows.add(notebook)

windows.show_all

Gtk.main




