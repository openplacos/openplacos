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
    # Parse Yaml correponding to the model of sensor
    if meas_["model"]
		#parse yaml
		#---
		# FIXME : model's yaml will be change, maybe
		#+++
		model = YAML::load(File.read( $PATH_SENSOR + meas_["model"] + ".yaml"))[meas_["model"]]
		# create the defined interface
		@interface = Dbus_interface.new(model["driver"]["interface"]).dup
		if model["driver"]["option"]
			@option = model["driver"]["option"].dup
		else
			@option = Hash.new
		end
		
		@ttl = model["driver"]["ttl"]
	
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
		@proxy_iface = proxy[@interface.get_name]
	end
	
	#measure from sensor
	def get_value
		if (Time.new.to_f - @last_mesure) > @ttl
				@last_mesure = Time.new.to_f
			    @value = @proxy_iface.read(@option)
		end
		return @value		
	end

end
