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
require 'Dispatcher.rb'
require 'timeout'

include REXML

module Dbus_proxy  # output

  def expose_on_dbus()
    Dispatcher.register_pin(self)

    @config.each_pair do |iface, methods| #iface level
      self.singleton_class.instance_eval{  
        dbus_interface "org.openplacos.component."+iface do
          
          dbus_method :read, "in option:a{sv}" do |option|
            
            [self.read(iface, option)]
          end  
          
          dbus_method :write, "out return:v, in value:v, in option:a{sv}" do 
            [self.write(iface, option)]
          end  
        end
      }
    end
  end

  def read(iface_, option_) # fork/thread specific ?
    
  end
  
  def write(iface_, option_)# fork/thread specific ?
    
  end

  def wait_for_component()  # check component started
    # fork/thread specific ?
    @path_dbus = "org.openplacos.components." + @name.downcase
    @timeout = 5

    begin
      Timeout::timeout(@timeout) { # allow a maximum time of #timeout second for the driver launch
        begin
          #launch the driver with dbus autolaunch
          component_service = Bus.service(@path_dbus) 
          component_service.introspect
        rescue
          sleep 0.1
<<<<<<< HEAD
          retry
        end
=======
        end
        retry
>>>>>>> 51af813c1c105bbcb0eeb4e2168800ea138d2e1e
      }
    rescue Timeout::Error 
      @top.dbus_plugins.error("Autolaunch of  #{@name}, component #{@path_dbus} failed",{})
      raise "Autolaunch of  #{@name}, component #{@path_dbus} failed"
    end
    
  end
end

<<<<<<< HEAD

=======
  
>>>>>>> 51af813c1c105bbcb0eeb4e2168800ea138d2e1e
