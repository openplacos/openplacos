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

if File.symlink?(__FILE__)
  PATH =  File.dirname(File.readlink(__FILE__))
else 
  PATH = File.expand_path(File.dirname(__FILE__))
end

class Plugin

  #1 Plugin definition in yaml config
  #2 Top reference
  def initialize(plugin_, top_) # Constructor
    @name   = plugin_["name"]
    @path   = plugin_["path"]
    @method = plugin_["method"]
    @class  = plugin_["name"].to_s.capitalize
    @exec   = PATH + plugin_["exec"] # To be patched with Patchname class

#    if (@method == "thread")
    if (@method == "thread")
      Thread.new{
         start_plug_thread()
      }
    else
      p = Process.fork{ # First fork
     
        # Double fork method
        # http://stackoverflow.com/questions/1740308/create-a-daemon-with-double-fork-in-ruby
        raise 'First fork failed' if (pid = fork) == -1
        exit unless pid.nil?

        Process.setsid
        raise 'Second fork failed' if (pid = fork) == -1
        exit unless pid.nil?
        
        Dir.chdir '/'
        File.umask 0000

        STDIN.reopen '/dev/null'
        STDOUT.reopen '/dev/null', 'a'
        STDERR.reopen STDOUT

        start_plug_fork()
      }
      Process.detach(p) # otherwise p will be zombified by OS
    end

    sleep 1 # We've to find a way to synchronize -- signal dbus ?
    @path_dbus = "org.openplacos.plugins." + @name.downcase
    @object_path = "/org/openplacos/plugin/" + @name.downcase
    @object_proxy = Bus.introspect(@path_dbus, @object_path)
    @proxy_plug = @object_proxy["org.openplacos.plugin"]

  end
  
  def start_plug_thread()
    @string_eval = ""
    @string_eval << "module "+ @name.capitalize
    @string_eval << File.open(@exec).read
    @string_eval << "end #EOF module " + @name

    eval @string_eval
  end
  
  def start_plug_fork()

    # http://ruby.about.com/od/advancedruby/a/The-Exec-Method.htm
    exec "#{@exec}"
  end

  def create_actuator(name_,config_)
    @proxy_plug.create_actuator(name_, config_)
  end

  def create_measure(name_,config_)
    @proxy_plug.create_measure(name_, config_)
  end

  def new_measure(name_,value_, config_)
    @proxy_plug.new_measure(name_, value_, config_)
  end

  def new_order(name_,value_, config_)
    @proxy_plug.new_order(name_, value_, config_)
  end

end
