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

require 'timeout'

class Measure

  attr_reader :name, :proxy_iface, :value, :config, :path, :informations, :regul, :top

  #1 Measure definition in yaml config
  #2 Top reference
  def initialize(meas_, top_) # Constructor

    @dependencies = nil
    @last_mesure = 0
    @value = nil
    @top = top_
    @check_lock = 0
    
    # Parse Yaml correponding to the model of sensor
    parse_config(meas_)
    @config = meas_
    
    #infor the plugins that a new measure has been created
    @top.dbus_plugins.create_measure(@name, @config)

  end

  def check(overpass_, ttl_)
    #1 overpass to 1 do not check dependencies, only at first step !
    #2 current ttl
    if (@check_lock==1 && overpass_==0)
      puts "\nDependencies loop detected for " + @path + " measure !"
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
  def plug(driver_,pin_)
    #1 proxy to card with defined interface
    #2 card name
    @driver = driver_
    proxy = @driver.objects[pin_]

    if not proxy.has_iface? @interface.get_name
      puts "Error : No interface " + @interface.get_name + " avalaibable for measure " + self.path
      Process.exit 1
    end
    if proxy[@interface.get_name].methods["read"]
      @proxy_iface = proxy[@interface.get_name]
    else
      puts "Error : No read method in interface " + @interface.get_name + "to plug with sensor" + self.path
      Process.exit 1
    end 
  end
  
  #measure from sensor
  def get_value
    time = Time.new.to_f;
    if (time - @last_mesure) > @ttl  # cache
      @last_mesure = time
      
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
        @value = self.convert(self.safe_read,dep)
        if !@value.nil?
          return @value
        else
          return "Error"
        end
      else
        return @value = self.safe_read
      end   
    
    end

    # informs the plugins 
    @top.dbus_plugins.new_measure(@path, @value, @option)
    
    return @value
  end
  
  #read a value on the driver and rescue if error
  def safe_read
    has_been_launch = false
    begin
      ret = @proxy_iface.read(@option)[0]
      return ret
    rescue DBus::Error
      if !has_been_launch
        @driver.launch_driver()
        has_been_launch = true
        retry
      else
        @top.dbus_plugins.error("Unable to contact driver for sensor #{ self.path}",{})
        raise "Unable to contact driver for sensor #{ self.path}"
      end
    end
  end

  def parse_config(config_)
    #parse config and add variable according to the config and the model
    #1 config given in yaml

    # Error processing
    if config_["driver"]["interface"].nil?
      abort "Error in model " + config_["model"] + " : interface is required "
    end
    if config_["name"].nil?
      abort "Error in config : name is required "
    end
 
    #for each keys of config
    @path         = config_["path"]
    @name         = config_["name"]
    @device_model = config_["model"]
    @informations = config_["informations"]
    @dependencies = config_["depends"]
    @interface    = Dbus_interface.new(config_["driver"]["interface"]).dup 

    if config_["driver"]["option"]
      @option = config_["driver"]["option"].dup
    else
      @option = Hash.new
    end  

    if config_["driver"]["ttl"]
      @ttl = config_["driver"]["ttl"]
    else
      @ttl = 0
    end
    
    if config_["conversion"]    
      eq = config_["conversion"].split
      eq.each_with_index { |block, index|

        if block.include? "%"
          if block.match("%self")
            eq[index] = block.gsub("%self","raw_value")
          else 
            eq[index] = "depends['" + block.delete!("%")+ "']"
          end
        end 
      }
      # add conversion method
      methdef = "def convert(raw_value,depends) \n return " + eq.join(" ") + "\n end"
      self.instance_eval(methdef) 
    end
        
    if config_["regul"]
      @regul = Regulation.new(config_["regul"], self)
    end
    
  end
  
end
