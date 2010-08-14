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

  attr_reader :name , :proxy_iface, :methods, :room ,:config ,:state, :card_name, :device_model

  #1 Measure definition in yaml config
  #2 Top reference
  def initialize(act_, top_) # Constructor
    
    @room = nil
    @state = -1
    @device_model = nil
    
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

      act_ = deep_merge(model,act_) # /!\ 
    end
    
    # Parse Yaml correponding to the model of actuator
    parse_config(act_)
    @config = act_
    @top = top_

  end

  # Plug the actuator to the proxy with defined interface 
  def plug(proxy_, card_name_) 
    if not proxy_.has_iface? @interface.get_name
      puts "Error : No interface " + @interface.get_name + " avalaibable for actuator " + self.name
      Process.exit 1
    end
    if proxy_[@interface.get_name].methods["write"]
      @proxy_iface = proxy_[@interface.get_name]
    else
      puts "Error : No write method in interface " + @interface.get_name + "to plug with actuator" + self.name
      Process.exit 1
    end 
    @card_name = card_name_
  end
  
  
  def parse_config(config_)
    #parse config and add variable according to the config and the model

    #Create hashes
    @methods = Hash.new    


    # Error processing
    if config_["driver"]["interface"].nil?
      abort "Error in model " + model["model"] + " : interface is required "
    end
    if config_["name"].nil?
      abort "Error in config : name is required "
    end

    #for each keys of config
    @room         = config_["room"]
    @name         = config_["name"]
    @device_model = config_["model"]
    @interface    = Dbus_interface.new(config_["driver"]["interface"]).dup
    

    # Get method defined in model
    config_["methods"].each { |method|
      #Check if value is defined for the method
      #value is required
      if not method["value"].nil?
        value = method["value"]
      else
        abort "Error in model " + config_["model"] + " : value is required for method " +  method["name"]
      end

      #Check if option is defined
      if method["option"]
        #Parse option define in yaml to a hash
        option = method["option"].inspect
      else
        #if no option is defined, send an empty hash
        option = "{}"
      end

      methdef = """
          def #{method["name"]}
            write( #{value}, #{option})
                end
        """
          self.instance_eval(methdef)
          @methods[method["name"]] = method["name"]
        }


    config_.each { |key, param| 
      
      case key
      when "driver"
        if param["option"]
          @option = value["option"].dup  ### What is value ?
        else
          @option = Hash.new
        end
      end
    }
  end
  
  def write( value_, option_)
    @proxy_iface.write( value_, option_)
    Thread.new{ 
      if $database.is_traced(self.name)
        flow = Database::Flow.create(:date  => Time.new,:value => to_float(value_)) 
        device =  Database::Device.find(:first, :conditions => { :config_name => self.name })
        actuator =  Database::Actuator.find(:first, :conditions => { :device_id => device.id })
        Database::Instruction.create(:flow_id => flow.id,
                                     :actuator_id => actuator.id)
      end
    }
    @state = value_
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
  
  def to_float(arg)
    case arg
    when true
      return 1.0
    when false
      return 0.0
    else
      return arg.to_f
    end     
  end


end
