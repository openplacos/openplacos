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


require 'dbus-openplacos'
include REXML

# List of local include
require 'Dbus-interfaces_acquisition_card.rb'



class Dbus_debug < DBus::Object
  # Create an interface.
  dbus_interface "org.openplacos.server.analog" do
    # Create generic interface
    dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
      return @proxy["org.openplacos.driver.analog"].write(value, option)
    end # End of dbus_method :write
    
    dbus_method :read, "out return:v, in option:a{sv}" do  |option|
      return @proxy["org.openplacos.driver.analog"].read(option)
    end  # End of dbus_method :read_analog

  end # End of dbus_interface analog

  dbus_interface "org.openplacos.server.digital" do  
    dbus_method :read, "out return:v, in option:a{sv}" do  |option|
      return @proxy["org.openplacos.driver.digital"].read(option)
    end # End of dbus_method :read_digital

    dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |value, option|
      return @proxy["org.openplacos.driver.digital"].write(value, option)
    end
  end # End of dbus_interface digital
  
  #1 Dbus service path
  #2 proxy object to debug
  def initialize (path_, proxy_obj_)
    # DBus constructor
    super("Debug/" + path_)
    
    @proxy = proxy_obj_
  end # End of initialize

end # End of class Dbus_debug 


class Dbus_debug_measure < DBus::Object
  # Create an interface.
  dbus_interface "org.openplacos.server.measure" do
    dbus_method :value, "out return:v" do 
      return @meas.get_value
    end  
  end 


  def initialize (meas_)
    # DBus constructor
   
    @meas = meas_
    
	super("Measure/" + meas_.name)
	
  end # End of initialize

end # End of class Dbus_debug_measure 

class Dbus_debug_actuator < DBus::Object
  

  def initialize (act_)
    # DBus constructor

	@act = act_ 
	
	#generates string of dbus methods 
	dbusmethods = define_dbus_methods(@act.methods)
	
	# add dbus methods to the class instance
	self.class.instance_eval(dbusmethods)
	
	super("Actuator/" + act_.name)
	
  end # End of initialize

	def define_dbus_methods(methods)
		methdef =    "dbus_interface 'org.openplacos.server.actuator' do \n"
    
		methods.each_value { |name|
			methdef +=     "dbus_method :" + name + ", 'out return:v' do \n return @act." + name + " \n end \n "
		}
		methdef += "end"
		
	end


end # End of class Dbus_debug_measure 

