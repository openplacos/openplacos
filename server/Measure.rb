#/usr/bin/ruby -w

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


$PATH_SENSOR = "../components/sensors/"


class Measure

  attr_reader :name , :proxy_iface, :value ,:room, :config, :card_name, :device_model, :informations

  #1 Measure definition in yaml config
  #2 Top reference
  def initialize(meas_, top_) # Constructor

    @dependencies = nil
    @room = nil
    @device_model = nil
    
    #detec model and merge with config
    if meas_["model"]
      #parse yaml
      #---
      # FIXME : model's yaml will be change, maybe
      #+++
      model = YAML::load(File.read( $PATH_SENSOR + meas_["model"] + ".yaml"))[meas_["model"]]
      
      
      #---
      # FIXME : merge delete similar keys, its not good for somes keys (like driver)
      #+++
      meas_ = deep_merge(model,meas_) # /!\ 

     
    end
    # Parse Yaml correponding to the model of sensor
    parse_config(meas_)
    @config = meas_
    @last_mesure = 0
    @value = nil     

    @top = top_
    @check_lock = 0

  end

  def check(overpass_, ttl_)
    #1 overpass to 1 do not check dependencies, only at first step !
    #2 current ttl
    if (@check_lock==1 && overpass_==0)
      puts "\nDependencies loop detected for " + @name + " measure !"
      puts "Please check dependencies for this measure"
      Process.exit 1
    end
    if (ttl_ == 0)
      return
    end
    if (@dependencies != nil)
      @dependencies.each_value { |dep|
        @top.measures[dep].check(0, ttl_ - 1)
      }
    end
    return 
  end

  def sanity_check()
    @check_lock = 1
    # Check overpass for first time
    self.check(1, @top.measures.length())
    @check_lock = 0
  end

  # Plug the measure to the proxy with defined interface 
  def plug(proxy_, card_name_)
    #1 proxy to card with defined interface
    #2 card name


    if not proxy_.has_iface? @interface.get_name
      puts "Error : No interface " + @interface.get_name + " avalaibable for measure " + self.name
      Process.exit 1
    end
    if proxy_[@interface.get_name].methods["read"]
      @proxy_iface = proxy_[@interface.get_name]
    else
      puts "Error : No read method in interface " + @interface.get_name + "to plug with sensor" + self.name
      Process.exit 1
    end 
    @card_name = card_name_
  end
  
  #measure from sensor
  def get_value
    if (Time.new.to_f - @last_mesure) > @ttl
      @last_mesure = Time.new.to_f
      
      if self.methods.include?("convert") # if convert fonction exist ?

        if @dependencies
            #build hash of dependencies
            dep = @dependencies.dup
            #fill hash with values of dependencies
            dep.each_pair{ |key, meas|
              #---
              #FIXME : I don't know why the result of get_value is an array, maybe VP or ruby-dbus variant
              #+++
              dep[key] = @top.measures[meas].get_value
            }
        else
            dep = {}
        end
        @value = self.convert(@proxy_iface.read(@option)[0],dep)
      else
        @value = @proxy_iface.read(@option)[0]
      end
    Thread.new{ 
        flow = Database::Flow.create(:date  => Time.new,:value => @value) 
        device =  Database::Device.find(:first, :conditions => { :config_name => self.name })
        sensor =  Database::Sensor.find(:first, :conditions => { :device_id => device.id })
        Database::Measure.create(:flow_id => flow.id,
                                 :sensor_id => sensor.id)
   }
    end
    return @value   
  end

  def parse_config(config_)
    #parse config and add variable according to the config and the model
    #1 config given in yaml
    
    #for each keys of config 
    config_.each {|key, param| 
    # Do we need this loop ?
      
      case key
      when "room"
        @room = param
      when "name"
        @name = param
        
      when "model"
        @device_model = param
      
      when "informations"
        @informations = param
        
      when "driver"
        if param["option"]
          @option = value["option"].dup
        else
          @option = Hash.new
        end
        
        if param["interface"]
          @interface = Dbus_interface.new(param["interface"]).dup
        else
          abort "Error in model " + config_["model"] + " : interface is required "
        end
        
        if param["ttl"]
          @ttl = config_["driver"]["ttl"]
        else
          @ttl = 0
        end
        
      when "depends"
        @dependencies = param

      when "conversion"
        eq = config_["conversion"].split
        eq.each_with_index { |block, index|

          if block.include? "%"
            if block=="%self"
              eq[index] = "raw_value"
            else 
              eq[index] = "depends['" + block.delete!("%")+ "']"
            end
          end 
        }
        # add conversion method
        methdef = "def convert(raw_value,depends) \n return " + eq.join(" ") + "\n end"
        self.instance_eval(methdef)   
        
      end
      
    }
  end
  
  def deep_merge(oldhash,newhash)
    oldhash.merge(newhash) { |key, oldval ,newval|
      case oldval.class.to_s
      when "Hash"
        deep_merge(oldval,newval)
      when "Array"
        oldval.concat(newval)
      else
        newval
      end
    }
  end
  
end
