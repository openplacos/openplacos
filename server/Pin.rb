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

include REXML



class Pin_input < DBus::ProxyObject
  attr_reader :name

  def initialize(name_, config_, component_, method_)
    @config    = config_
    @name      = name_
    @component = component_
    @method    = method_

    super(InternalBus, "org.openplacos.components.#{@component.name}", @name)
  end


end

class Pin_output < DBus::Object
  def initialize(name_, config_, component_, method_)
    @config    = config_
    @name      = name_
    @component = component_
    @dbus_name = "/#{@component.name}#{@name}"
    @method    = method_

    
    super(@dbus_name)

  end

  
  def expose_on_dbus()
    Dispatcher.register_pin(self)

    dis = Dispatcher.instance

    @config.each_pair do |iface, methods| #iface level
      self.singleton_class.instance_eval{  
        dbus_interface "org.openplacos.component."+iface do
          
          #         methods.each do |meth|
          #          dbus_method meth.name.to_sym, meth.prototype do |option|
          #        end
          dbus_method :read, "in option:a{sv}" do |arg|
            
            [dis.call(objet, iface,meth.name, *arg)]
          end  
          
          dbus_method :write, "out return:v, in value:v, in option:a{sv}" do 
            [self.write(iface, option)]
          end  
        end
      }
    end
  end

  def read
  end
  
  def write
  end

end

