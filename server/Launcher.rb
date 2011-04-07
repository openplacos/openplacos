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

class Launcher
  
  #1 Absolute path to module to be launched
  #2 Launching method
  #3 Top reference
  def initialize(path_, method_, launch_config_, top_) # Constructor
    @path   = path_
    @method = method_
    @launch_config = launch_config_
    @command_string = ""

    if (!File.exists?(@path))
        top_.dbus_plugins.error("Can't find driver for card #{card_["name"]}, driver #{@path_dbus} is maybe unavailable",{})
    end
      

    if (@method != "disable")
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
    end
  end
  
  def start_plug_thread()
    @argv_string = "ARGV[] = ["
    @launch_config.each { |key, value|
      @argv_string << "\"--#{key}=#{value}\", "
    }
    @argv_string << "]"
    @string_eval = ""
    @string_eval << "module "+ @name.capitalize + "\n"
    @string_eval << @argv_string
    @string_eval << File.open(@path).read
    @string_eval << "end # end of module " + @name
    eval(@string_eval,TOPLEVEL_BINDING,@path) # eval in an empty binding
  end
  
  def start_plug_fork()
    
    @command_string = @path
    @launch_config.each { |key, value|
      @command_string << " --#{key}=#{value}"
    }

    # http://ruby.about.com/od/advancedruby/a/The-Exec-Method.htm
    exec "#{@command_string}"
  end

end
