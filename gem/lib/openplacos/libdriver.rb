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

ENV["DBUS_THREADED_ACCESS"] = "1" #activate threaded dbus
require 'dbus-openplacos'


module Openplacos
  module Driver
  
  class GenericPin < DBus::Object

    def set_off(iface_req_)
      if (@init != iface_req_) # Iface changed, turn off previous one
         if(self.methods.include?("exit_"+@init))
           eval("exit_"+@init+"()")
        end     
      end
    end


    def write(iface_, value_, option_)
      
      set_off(iface_)
      if (@input == 1)# Set output
        if(self.methods.include?("set_output"))
          self.set_output()
        end
        @input = 0; 
      end

      if (@init != iface_) # If the iface needs to be init
        if(self.methods.include?("init_"+iface_))
          eval("init_#{iface_}()")
        end
        @init = iface_
      end
      eval("write_#{iface_}(value_, option_)")

    end

    def add_write(iface_)
      dbusdef = "dbus_interface 'org.openplacos.#{iface_}' do
                    dbus_method :write, 'out return:v, in value:v, in option:a{sv}' do |value, option|
                      return self.write( \"#{iface_}\", value,option)
                    end 
                  end"

      self.singleton_class.instance_eval(dbusdef)
    end

    def read(iface_, option_)
       set_off(iface_)
      if (@input == 0)# Set input
        if(self.methods.include?("set_input"))
          self.set_input()
        end
        @input = 1; 
      end

      eval("read_#{iface_}( option_)")

    end
    

    def add_read(iface_)
      dbusdef = "dbus_interface 'org.openplacos.#{iface_}' do
                    dbus_method :read, 'out return:v, in option:a{sv}' do |option|
                      return self.read(\"#{iface_}\", option)
                    end 
                  end"
      self.singleton_class.instance_eval(dbusdef)
    end
    
    def add_read_and_write(iface_) # dbus do not merge methods in interface if they are not define in the same time
      dbusdef = "dbus_interface 'org.openplacos.#{iface_}' do
                    dbus_method :read, 'out return:v, in option:a{sv}' do |option|
                       return self.read(\"#{iface_}\",option)
                    end
                    dbus_method :write, 'out return:v, in value:v, in option:a{sv}' do |value, option|
                     return self.write(\"#{iface_}\", value,option)
                    end 
                  end"

      self.singleton_class.instance_eval(dbusdef)
    end
   
    
    def initialize(path_, write_intfs_, read_intfs_) # path name , an array of string of interface wich write methods, an array of 
      @init = ""
      @input = nil

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
end
end
