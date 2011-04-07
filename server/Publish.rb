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


include REXML

# List of local include
require 'Dbus-interfaces_acquisition_card.rb'


class Dbus_measure < DBus::Object
  # Create an interface.
  dbus_interface "org.openplacos.server.measure" do
    dbus_method :value, "out return:v" do 
      return @meas.get_value
    end  
  end 
  
  dbus_interface "org.openplacos.server.config" do
    dbus_method :getConfig, "out return:a{sv}" do 
      [@meas.config]
    end  
  end 


  def initialize (meas_)
    # DBus constructor
   
    @meas = meas_
    super(@meas.path)
    if (meas_.regul)
      dbus_regul_iface()
    end

  end # End of initialize

  def dbus_regul_iface()
    
    methdef =    'dbus_interface "org.openplacos.server.regul" do
    dbus_method :set, "in option:a{sv}" do |option|
      [@meas.regul.set(option)]
    end  
    dbus_method :unset do 
      [@meas.regul.unset]
    end  
    dbus_method :state, "out return:v" do
      [@meas.regul.state]
    end 
  end '

    # evualates methdef
    self.singleton_class.instance_eval(methdef)
  end

end # End of class Dbus_debug_measure 

class Dbus_actuator < DBus::Object
  
  dbus_interface "org.openplacos.server.config" do
    dbus_method :getConfig, "out return:a{sv}" do 
      [@act.config]
    end
  end 
  

  def initialize (act_)
    # DBus constructor

  @act = act_ 
  #generates string of dbus methods 
  dbusmethods = define_dbus_methods(@act.methods)
  
  # add dbus methods to the class instance
  self.singleton_class.instance_eval(dbusmethods)

  super(@act.path)

  end # End of initialize

  def define_dbus_methods(methods)
    methdef =    "dbus_interface 'org.openplacos.server.actuator' do \n "
    methdef +=   "dbus_method :state, 'out return:a{sv}' do \n return [@act.state] \n end \n"
    methods.each_value { |name|
      methdef +=     "dbus_method :" + name + ", 'out return:v' do \n return @act." + name + " \n end \n "
    }
    methdef += "end"
    
  end


end # End of class Dbus_debug_measure 

class Server < DBus::Object

  dbus_interface "org.openplacos.server.information" do
    dbus_method :usbDiscover, "out return:as" do 
      [self.getUsbDevices]
    end  
  end 

  def initialize
    super("server")
  end

  def getUsbDevices
    devices = Array.new
    pid_file =  YAML::load(File.read($INSTALL_PATH + "/pid.yaml"))
    lsusb =  `#{$INSTALL_PATH}/scripts/get_id_usb.rb` #execute lsusb command
    pid_file["lsusb"].each { |dev|
      if lsusb.match(dev["pid"])
        devices.push(dev["driver"])
      end
    }
    devices
  end
end

class Dbus_Plugin < DBus::Object
  attr_accessor :server_ready

  dbus_interface "org.openplacos.plugins" do
    dbus_signal :create_measure, "in measure_name:s, in config:a{sv}"
    dbus_signal :create_actuator, "in actuator_name:s, in config:a{sv}"
    dbus_signal :new_measure, "in measure_name:s, in value:v, in options:a{sv}"
    dbus_signal :new_order, "in actuator_name:s, in value:v, in options:a{sv}"
    dbus_signal :create_card, "in card_name:s, in config:a{sv}" 
    dbus_signal :quit,""
    dbus_signal :ready,""
    dbus_signal :error,"in error:s, in options:a{sv}"

    dbus_method :is_server_ready, "out ready:b" do 
      return @server_ready
    end   
        
  end
  
  def initialize
    super("/plugins")
    @server_ready = false
  end

end

class Authenticate < DBus::Object

  def initialize(users_)
    @users = users_
    super("/Authenticate")
  end
  dbus_interface "org.openplacos.authenticate" do
    dbus_method :authenticate, "in login:s, in hash:s, out valid:b, out permissions:a{sv}" do |login,hash|
      
      valid = false
      permissions = Hash.new
      
      if login == "anonymous"
        valid = true
        permissions = @users["anonymous"].permissions
      end
      
      if @users[login]
        if @users[login].hash == hash
          valid = true
          permissions = @users[login].permissions
        end
      end
      if valid == false
        sleep rand
      end
      return  [valid,permissions]
    end  
  end

end
