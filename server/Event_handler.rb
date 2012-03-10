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


class Event_Handler < DBus::Object
  include Singleton

  attr_accessor :server_ready, :plugin_count

  dbus_interface "org.openplacos.plugins" do
    dbus_signal :create_component, "in component_name:s, in config:a{sv}"
    dbus_signal :new_read, "in measure_name:s, in value:v, in options:a{sv}"
    dbus_signal :new_write, "in actuator_name:s, in value:v, in options:a{sv}"
    dbus_signal :quit,""
    dbus_signal :error,"in error:s, in options:a{sv}"

    dbus_method :print, "in level:i, in message:s" do |level, message|
      puts message
      STDOUT.flush
    end
    
    dbus_method :exit, "in status:i, in message:s" do |status, message|
      puts "Error:: " + message
      STDOUT.flush
      Top.instance.quit # not suffisant but enough for quitting forked components
      Process.exit status
    end
  end
  
  def initialize
    super("/plugins")
  end

end
