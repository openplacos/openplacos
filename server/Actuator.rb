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

  attr_reader :name , :proxy_iface

  #1 Measure definition in yaml config
  #2 Top reference
  def initialize(act_, top_) # Constructor

    # Class variables
    @name = act_["name"]
    
    @interface=nil
    # Parse Yaml correponding to the model of sensor
    if act_["model"]
		#parse yaml
		#---
		# FIXME : model's yaml will be change, maybe
		#+++
		model = YAML::load(File.read( $PATH_ACTUATOR + act_["model"] + ".yaml"))[act_["model"]]
		# create the defined interface
		@interface = Dbus_interface.new(model["driver"]["interface"]).dup
		if model["driver"]["option"]
			@option = model["driver"]["option"].dup
		else
			@option = Hash.new
		end
	
	end
    @top = top_

  end

   # Plug the actuator to the proxy with defined interface 
	def plug(proxy) 
		@proxy_iface = proxy[@interface.get_name]
	end
	

end
