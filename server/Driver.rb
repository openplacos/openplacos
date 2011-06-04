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

# lib include
include REXML


# local include
require 'Dbus-interfaces.rb'
require 'Launcher.rb'
require 'timeout'

class Driver < Launcher

	if File.symlink?(__FILE__)
	  PATH =  File.dirname(File.readlink(__FILE__))
	else 
	  PATH = File.expand_path(File.dirname(__FILE__))
	end

  attr_reader :objects, :path_dbus

  #1 Name of service
  def initialize(card_, top_) # Constructor

    # Class variables
    @name = card_["name"]
    @method = card_["method"]
    @top = top_
    if card_["exec"]
		#file can be find
      @path   = PATH + "/" + card_["exec"]
    end
    if card_["method"] == "debug"
      @method = "debug"
    else
      @method = "fork"
    end

    @plug = card_["plug"]
    @path_dbus = "org.openplacos.drivers." + @name.downcase
    
    @timeout = card_["timeout"] || 5 # default value 5 second
   
    @launch_config = card_.dup
    
    @launch_config.delete("exec")
    @launch_config.delete("plug")
    @launch_config.delete("timeout")
    @launch_config.delete("method")

    #create the launcher
    super(@path, @method,  @launch_config, @top)

    #launch the driver
    launch_driver()
    
    @objects = Hash.new

    @plug.each_pair do |pin,object_path|
      
      next if object_path.nil?

      # Get object proxy
      begin
        obj_proxy = Bus.introspect(@path_dbus, pin)
      rescue
        top_.dbus_plugins.error("Can't find #{pin} for card #{card_["name"]}, driver #{@path_dbus} is maybe unavailable",{})
        raise "Can't find #{pin} for card #{card_["name"]}, driver #{@path_dbus} is maybe unavailable"
      end
      @objects[pin]=obj_proxy
      
      # Welcome to Real Informatik
      # Here is a workaround to https://bugs.freedesktop.org/show_bug.cgi?id=25125
      obj_proxy.interfaces().each { |iface_name|
        obj_proxy[iface_name].methods.keys.each { |method|
          if (method == "read_"+ iface_name.split(".").reverse[0])
            $global.trace "redefine " + method + "() to read() for object " + pin
            aliasdef = "alias read " + "read_" + iface_name.split(".").reverse[0]
            obj_proxy[iface_name].instance_eval(aliasdef)
            obj_proxy[iface_name].methods["read"] =  obj_proxy[iface_name].methods["read_" + iface_name.split(".").reverse[0]]
          end
          
          if (method == "write_"+ iface_name.split(".").reverse[0])
            $global.trace "redefine " + method + "() to write() for object " + pin
            aliasdef = "alias write " + "write_" + iface_name.split(".").reverse[0]
            obj_proxy[iface_name].instance_eval(aliasdef)
            obj_proxy[iface_name].methods["write"] =  obj_proxy[iface_name].methods["write_" + iface_name.split(".").reverse[0]]
          end
        } 
      }
    end
    

  end #  End of initialize

  def launch_driver()
    has_been_launched = false
    
    begin
      Timeout::timeout(@timeout) { # allow a maximum time of #timeout second for the driver launch
        begin
          #launch the driver with dbus autolaunch
          driver = Bus.service(@path_dbus) 
          driver.introspect
        rescue # driver is not present on the bus, launch it
          if !has_been_launched # wait until driver is ready
            self.launch
            has_been_launched = true
          else
            sleep 0.1
          end
          retry
        end
      }
    rescue Timeout::Error 
      @top.dbus_plugins.error("Autolaunch of  #{@name}, driver #{@path_dbus} failed",{})
      raise "Autolaunch of  #{@name}, driver #{@path_dbus} failed"
    end
  end

end # End of Driver




