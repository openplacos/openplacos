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
          retry
        end
        
        #if launched, grab the /component proxy object
        @component_proxy = component_service.object("/component")        
      }
    rescue Timeout::Error 
      Globals.error("Autolaunch of  #{@name}, component #{@path_dbus} failed")
    end
    
    @inputs.each do |input|
      input.introspect
    end

  end
  
end
