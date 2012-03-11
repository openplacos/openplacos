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

    # level is Logger level:  0: FATAL; 1: ERROR; 2; WARN; 4: INFO; 5: DEBUG
    # refers to this http://www.ruby-doc.org/stdlib-1.9.3/libdoc/logger/rdoc/Logger.html
    # message will be print to log
    dbus_method :print, "in level:i, in message:s" do |level, message|
      error_level = [Logger::FATAL, Logger::ERROR, Logger::WARN, Logger::INFO, Logger::DEBUG]
      if (level==0)
        puts message
        STDOUT.flush
      end

      if (level > 4)
        level = 2 # clip to WARN
      end
      Globals.trace(message, error_level[level])
      
    end
    
    # Status will be status of opos server
    # message will print in log to debug
    dbus_method :exit, "in status:i, in message:s" do |status, message|
      Globals.error(message, status)
    end
  end
  
  def initialize
    super("/plugins")
  end

end
