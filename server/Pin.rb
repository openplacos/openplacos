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

module Pin
  
  def register
    dis = Dispatcher.instance
    dis.register_pin(self)
  end

  def match_iface(pin_)
  end
  
  # this method set iface to a prefered one when an undertimnation is raised
  # this method is called by wire since the prefered iface is declared in mapping config
  def set_prefered_iface(iface_) 
    @prefered_iface = iface_
  end



end

class Pin_input < DBus::ProxyObject
  include Pin
  attr_reader :name, :dbus_name, :config

  def initialize(name_, config_, component_, method_)
    @config         = config_ # config from component introspect
    @name           = name_
    @component      = component_
    @method         = method_
    @dispatcher     = Dispatcher.instance
    @dbus_name      = "/#{@component.name}#{@name}"
    @prefered_iface = ""

    register
    super(InternalBus, "org.openplacos.components.#{@component.name}", @name)
  end

  def get_iface(iface_)
    return "org.openplacos.#{iface_}"
  end

  def method_exec(iface_, method_, *args_) 
    return self[get_iface(iface_)].send(method_, *args_)
  end

  def match_iface(pin_)
    match = {}
    candidate = nil
    if pin_.is_a?(Pin_output)
      pin_.config.keys.each { |iface|
        num_candidate = 0
        @config.keys.each{ |i|
          if iface.include?(i)
            candidate = i
            num_candidate +=1
          end
        }
        if num_candidate != 1
          if @prefered_iface != "" && iface.include?(@prefered_iface)
            match[iface] = @prefered_iface
            next
          end
          Globals.error("Can't determine how to plug #{pin_.name} with #{@name}", 2)
        else
          match[iface] = candidate
        end
      }
    end 
    match
  end
 
end

class Pin_output < DBus::Object
  include Pin
  attr_reader :name, :dbus_name, :config

  def initialize(name_, config_, component_, method_)
    @config    = config_ # config from component introspect
    @name      = name_
    @component = component_
    @dbus_name = "/#{@component.name}#{@name}"
    @method    = method_
    
    register
    super(@dbus_name)
  end

  
  def expose_on_dbus()
    dis = Dispatcher.instance

    @config.each_pair do |iface, methods| #iface level
      self.singleton_class.instance_eval{  
        dbus_interface "org.openplacos."+iface do
          
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
  include Pin
  attr_reader :dbus_name

  def initialize(dbus_name_)
    @dbus_name = dbus_name_
    register
    super(@dbus_name)
  end
  
  def expose_on_dbus()
    dis = Dispatcher.instance
    pin_plugs = dis.get_plug(@dbus_name)
    pin_plugs.each do |pin|
      pin.config.each do |iface, meths|
        self.singleton_class.instance_eval do
          dbus_interface "org.openplacos.#{iface}" do
            meths.each { |m|
              add_dbusmethod m.to_sym do |*args|
                dis.call(self.dbus_name, iface,m, *args)
              end
            }
          end
        end
      end
    end
  end

  def self.add_dbusmethod(sym,&block)
    case sym
    when :read
      prototype = "out return:v, in option:a{sv}"
    when :write
      prototype = "out return:v, in value:v, in option:a{sv}"
    end
    dbus_method(sym,prototype,&block)
  end


end


class Pin_web  
  include Pin
  attr_reader :dbus_name, :ifaces

  def initialize(dbus_name_)
    @dbus_name = dbus_name_
    register
    @ifaces = nil
  end
  
  def update_ifaces # plugged ifaces will be mine
    @ifaces = Dispatcher.instance.get_plugged_ifaces(@dbus_name)
  end
  
  def introspect
    intro = Hash.new
    Dispatcher.instance.get_plug(@dbus_name).each do |pin|
      intro.merge!(pin.config)
    end
    intro
  end

end
