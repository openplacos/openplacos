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


$PATH_ACTUATOR = "../components/actuators/"

class Actuator

  attr_reader :name , :proxy_iface, :methods, :room ,:config ,:state

  #1 Measure definition in yaml config
  #2 Top reference
  def initialize(act_, top_) # Constructor
    
    @room = nil
    @state = -1
    
    #detect model and merge with config
    if act_["model"]
      #parse yaml
      #---
      # FIXME : model's yaml will be change, maybe
      #+++
      model = YAML::load(File.read( $PATH_ACTUATOR + act_["model"] + ".yaml"))[act_["model"]]

      #---
      # FIXME : merge delete similar keys, its not good for somes keys (like methods)
      #+++    
      act_ = deep_merge(model,act_)
    end
    
    # Parse Yaml correponding to the model of sensor
    parse_config(act_)
    @config = act_
    @top = top_

  end

  # Plug the actuator to the proxy with defined interface 
  def plug(proxy) 
    if proxy[@interface.get_name].methods["write"]
      @proxy_iface = proxy[@interface.get_name]
    else
      puts "Error : No write method in interface " + @interface.get_name + "to plug with actuator" + self.name
      Process.exit 1
    end 
  end
  
  
  def parse_config(model)
    #parse config and add variable according to the config and the model
    
    #for each keys of config
    model.each {|key, param| 
      
      case key
      when "room"
        @room = param
      when "name"
        @name = param
      when "driver"
        if param["option"]
          @option = value["option"].dup
        else
          @option = Hash.new
        end
        
        if param["interface"]
          @interface = Dbus_interface.new(param["interface"]).dup
        else
          abort "Error in model " + model["model"] + " : interface is required "
        end
        
      when "methods"
        @methods = Hash.new
        param.each{ |method|
          #Check if value is defined for the method
          #value is required
          if method["value"]
            value = method["value"]
          else
            abort "Error in model " + model["model"] + " : value is required for method " +  method["name"]
          end

          #Check if option is defined
          if method["option"]
            #Parse option define in yaml to a hash
            option = method["option"].inspect
          else
            #if no option is defined, send an empty hash
            option = "{}"
          end

          methdef = "def " + method["name"] + " \n @proxy_iface.write( " + value + "," + option + ") \n @state = #{value} \n end"
          self.instance_eval(methdef)
          @methods[method["name"]] = method["name"]
        }
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
