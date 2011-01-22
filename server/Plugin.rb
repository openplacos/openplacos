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
require 'timeout'
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
    @exec   = PATH + "/" + plugin_["exec"] # To be patched with Patchname class
    
    top_.dbus_plugins.config_queue.push plugin_
    
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
    
    begin # if plugin don't start within the next 10 seconds, go ahead.
      Timeout::timeout(10) do 
        name = top_.dbus_plugins.ready_queue.pop
        puts "Plugin named #{name} is started"
      end
    rescue Timeout::Error
      top_.dbus_plugins.config_queue.clear
      top_.dbus_plugins.error("Plugin #{@name} do not respond in time, try the next plugin",{})
      puts "Plugin #{@name} do not respond in time, try the next plugin"
    end

  end
  
  def start_plug_thread()
    @string_eval = ""
    @string_eval << "module "+ @name.capitalize
    @string_eval << File.open(@exec).read
    @string_eval << "end # end of module " + @name

    eval @string_eval
  end
  
  def start_plug_fork()

    # http://ruby.about.com/od/advancedruby/a/The-Exec-Method.htm
    exec "#{@exec}"
  end

end
