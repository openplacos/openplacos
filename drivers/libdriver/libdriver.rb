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

require 'dbus'

class GenericPin < DBus::Object


  def add_write(iface_)
    dbusdef = "dbus_interface 'org.openplacos.driver.#{iface_}' do
                  dbus_method :write, 'out return:v, in value:v, in option:a{sv}' do |value, option|
                    return self.write_#{iface_}(value,option)
                  end 
                end"
    self.singleton_class.instance_eval(dbusdef)
  end

  
  def add_read(iface_)
    dbusdef = "dbus_interface 'org.openplacos.driver.#{iface_}' do
                  dbus_method :read, 'out return:v, in option:a{sv}' do |option|
                    return self.read_#{iface_}(option)
                  end 
                end"
    self.singleton_class.instance_eval(dbusdef)
  end
  
  def add_read_and_write(iface_) # dbus do not merge methods in interface if they are not define in the same time
    dbusdef = "dbus_interface 'org.openplacos.driver.#{iface_}' do
                  dbus_method :read, 'out return:v, in option:a{sv}' do |option|
                    return self.read_#{iface_}(option)
                  end
                  dbus_method :write, 'out return:v, in value:v, in option:a{sv}' do |value, option|
                    return self.write_#{iface_}(value,option)
                  end 
                end"
    self.singleton_class.instance_eval(dbusdef)
  end
 
  
  def initialize(path_, write_intfs_, read_intfs_) # path name , an array of string of interface wich write methods, an array of 
    
    (write_intfs_ & read_intfs_).each { |iface|
      self.add_read_and_write(iface)
      self.instance_eval("self.extend(Module_write_#{iface})")
      self.instance_eval("self.extend(Module_read_#{iface})")
      write_intfs_.delete(iface)
      read_intfs_.delete(iface)
    }          
    
    write_intfs_.each{ |iface|
      self.add_write(iface)
      self.instance_eval("self.extend(Module_write_#{iface})")
    }
    
    read_intfs_.each{ |iface|
      self.add_read(iface)
      self.instance_eval("self.extend(Module_read_#{iface})")
    }
    super(path_)
    self.extend(Other_common_fonctions)
  end

end
