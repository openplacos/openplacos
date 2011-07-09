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
require 'Displatcher.rb'

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
end
  
module Dbus_proxy_input_thread

end

module Dbus_proxy_input_fork
  
end

module Dbus_proxy_output_thread
  include  Dbus_proxy_output
  include  Dbus_proxy_thread
end

module Dbus_proxy_output_fork
  include  Dbus_proxy_output
  include  Dbus_proxy_fork
end

module Dbus_proxy_input


  def read(iface_, option_)
    
  end
  
  def write(iface_, option_)
  
  end
end

end
