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

  dbus_interface "org.openplacos.server.regul" do
    dbus_method :set, "in return:a{sv}" do |option|
      [@meas.regul.set(option)]
    end  
    dbus_method :unset do 
      [@meas.regul.unset]
    end  
  end 

  def initialize (meas_)
    # DBus constructor
   
    @meas = meas_
    super(@meas.path)

  end # End of initialize

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
    pid_file =  YAML::load(File.read("pid.yaml"))
    lsusb =  `./scripts/get_id_usb.rb` #execute lsusb command
    pid_file["lsusb"].each { |dev|
      if lsusb.match(dev["pid"])
        devices.push(dev["driver"])
      end
    }
    devices
  end
end

