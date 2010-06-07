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

  attr_reader :name , :proxy_iface, :value

  #1 Measure definition in yaml config
  #2 Top reference
  def initialize(meas_, top_) # Constructor

    # Class variables
    @name = meas_["name"]
    
    @path_dbus = meas_["driver"]
    @object_list = meas_["object"]
    
    @dependencies = meas_["depends"]
    @interface=nil
    # Parse and interpret Yaml correponding to the model of sensor
    if meas_["model"]
		model_interpreter(meas_["model"])	
	end

	@last_mesure = 0
	@value = nil     

    @top = top_
    @check_lock = 0

    # Open a Dbus socket
    if (@path_dbus != nil)
      @driver = Bus.service(@path_dbus)
      @object_list.each do |obj|
        @object = @driver.object(obj)
      end
    end
  end

  def check(overpass_, ttl_)
    if (@check_lock==1 && overpass_==0)
      puts "\nDependencies loop detected for " + @name + " measure !"
      puts "Please check dependencies for this measure"
      Process.exit
    end
    if (ttl_ == 0)
      return
    end
    if (@dependencies != nil)
        @dependencies.each_value { |dep|
          @top.measure[dep].check(0, ttl_ - 1)
        }
      end
    return 
  end

  def sanity_check()
    @check_lock = 1
    # Check overpass for first time
    self.check(1, @top.measure.length())
     @check_lock = 0
  end

  # Plug the measure to the proxy with defined interface 
	def plug(proxy) 
		if proxy[@interface.get_name].methods["read"]
			@proxy_iface = proxy[@interface.get_name]
		else
			puts "Error : No read method in interface " + @interface.get_name + "to plug with sensor" + self.name
		end 
	end
	
	#measure from sensor
	def get_value
		if (Time.new.to_f - @last_mesure) > @ttl
				@last_mesure = Time.new.to_f
				
				if self.methods.include?("convert") # if convert fonction exist ?
					#build hash of dependencies
					dep = @dependencies.dup
					
					#fill hash with values of dependencies
					dep.each_pair{ |key, meas|
					#--- 
					#FIXME : I don't know why the result of get_value is an array, maybe VP or ruby-dbus variant
					#+++
						dep[key] = @top.measure[meas].get_value
					}
					
					@value = self.convert(@proxy_iface.read(@option)[0],dep)
				else
					@value = @proxy_iface.read(@option)[0]
				end
			    			    
		end
		return @value		
	end
	
	def model_interpreter(model_name)
		#parse yaml
		#---
		# FIXME : model's yaml will be change, maybe
		#+++
		
		model = YAML::load(File.read( $PATH_SENSOR + model_name + ".yaml"))[model_name]
		
		
		# create the defined interface
		@interface = Dbus_interface.new(model["driver"]["interface"]).dup
		
		# check if option for read(option) is defined
		if model["driver"]["option"]
			@option = model["driver"]["option"].dup
		else
			@option = Hash.new
		end
		
		# create TTL from model
		@ttl = model["driver"]["ttl"]
		
		#check for conversion fonction 
		if model["conversion"]
			
			eq = model["conversion"].split
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
		
	end

end
