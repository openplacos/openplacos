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
  attr_reader :name, :dbus_name

  def initialize(name_, config_, component_, method_)
    @config     = config_
    @name       = name_
    @component  = component_
    @method     = method_
    @dispatcher = Dispatcher.instance
    @dbus_name  = "/#{@component.name}#{@name}"

    dis = Dispatcher.instance
    dis.register_pin(self)
    super(InternalBus, "org.openplacos.components.#{@component.name}", @name)
  end

  def get_iface(iface_)
    return "org.openplacos.#{iface_}"
  end

  def method_exec(iface_, method_, *args_) 
    return self[get_iface(iface_)].send(method_, *args_)
  end
end

class Pin_output < DBus::Object
  attr_reader :name, :dbus_name

  def initialize(name_, config_, component_, method_)
    @config    = config_
    @name      = name_
    @component = component_
    @dbus_name = "/#{@component.name}#{@name}"
    @method    = method_
    
    dis = Dispatcher.instance
    dis.register_pin(self)

    super(@dbus_name)
  end

  
  def expose_on_dbus()
    dis = Dispatcher.instance

    @config.each_pair do |iface, methods| #iface level
      self.singleton_class.instance_eval{  
        dbus_interface "org.openplacos.component."+iface do
          
          dbus_method :read, "out return:v, in option:a{sv}" do |*arg|  
            return dis.call(self.dbus_name, iface,"read", *arg)
          end  
          
          dbus_method :write, "out return:v, in value:v, in option:a{sv}" do |*arg|
            return dis.call(self.dbus_name, iface,"write", *arg)
          end  
        end
      }
    end
  end
end


class Pin_export  < DBus::Object
  attr_reader :dbus_name

  def initialize(dbus_name_)
    @dbus_name = dbus_name_
    dis = Dispatcher.instance
    dis.register_pin(self)
  end
  
  def expose_on_dbus()
    dis = Dispatcher.instance
    pin_plugs = dis.get_plug(@dbus_name)
    iface_to_implement = Array.new
    puts pin_plugs.inspect
    pin_plugs.each do |pin|
      puts pin.methods
      iface_to_implement << pin.interfaces
    end
    puts iface_to_implement.inspect
  end
end

