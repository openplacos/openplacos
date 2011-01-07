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

class Actuator

  attr_reader :name, :proxy_iface, :methods, :config ,:state, :path

  #1 Measure definition in yaml config
  #2 Top reference
  def initialize(act_, top_) # Constructor
    
    @state = Hash.new
    @top = top_
    
    # Parse Yaml correponding to the model of actuator
    parse_config(act_)
    @config = act_ 

  end

  # Plug the actuator to the proxy with defined interface 
  def plug(proxy_) 
    if not proxy_.has_iface? @interface.get_name
      puts "Error : No interface " + @interface.get_name + " availabable for actuator " + self.path
      Process.exit 1
    end
    if proxy_[@interface.get_name].methods["write"]
      @proxy_iface = proxy_[@interface.get_name]
    else
      puts "Error : No write method in interface " + @interface.get_name + "to plug with actuator" + self.path
      Process.exit 1
    end 
  end
  
  
  def parse_config(model_)
    #parse config and add variable according to the config and the model

    #Create hashes
    @methods = Hash.new    


    # Error processing
    if model_["driver"]["interface"].nil?
      abort "Error in model " + model_["model"] + " : interface is required "
    end
    if model_["name"].nil?
      abort "Error in config : name is required "
    end

    #for each keys of config

    model_.each {|key, param| 
      
      case key
      when "path"
        @path = param
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
          if not method["value"].nil?
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

          methdef = """
          def #{method["name"]}
            write( #{value}, #{option})
             @state['name'] = \"#{method['name']}\"
             @state['value'] = \"#{value}\"
             @state['option'] = \"#{option}\"
          end
          """
          self.instance_eval(methdef)
          @methods[method["name"]] = method["name"]
    }
    end
    if model_["driver"]["option"]
      @option = model_["driver"]["option"].dup
    else
      @option = Hash.new
    end    
    }
  end
  
  def write( value_, option_)    
    @proxy_iface.write( value_, option_)
    Thread.new{ 
      if $database.is_traced(self.path)
        flow = Database::Flow.create(:date  => Time.new,:value => to_float(value_)) 
        device =  Database::Device.find(:first, :conditions => { :config_name => self.path })
        actuator =  Database::Actuator.find(:first, :conditions => { :device_id => device.id })
        Database::Instruction.create(:flow_id => flow.id,
                                     :actuator_id => actuator.id)
      end
    } if defined? $database

  end


end
