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
    @thread = nil
    @top = top_

    if (!File.exists?(@path))
        @top.dbus_plugins.error("File #{@path} doesnt exists",{})
        raise "File #{@path} doesnt exists"
    end

    @command_string = @path
    @launch_config.each { |key, value|
      @command_string << " --#{key}=#{value}"
    }

    if (@method == "debug") 
      puts @command_string
      @method = "disable"
    end
 
  end
  
  def launch() 
    if (@method != "disable")  #do nothing
      if (@method == "thread")  #launch in thread mode
        if @thread.nil? #check if thread has been already launched
          @thread = Thread.new{
            start_plug_thread()
          }
        else # if thread has been launch, you attempt to relaunch
          if @thread.alive? #check if thread are running (or sleeping)
            # Alive thread relaunch id forbiden
             @top.dbus_plugins.error("Attempt to relaunch a alive thread : #{@path} | it's forbiden",{})
             raise "Attempt to relaunch a alive thread : #{@path} | it's forbiden"
          else 
            #relaunch the thread
            @thread = Thread.new{
              start_plug_thread()
            }
          end 
        end 
      else 
        start_plug_fork()
      end 
    end 
  end 
  
  private
  
  def start_plug_thread()
    @argv_string = "ARGV = ["
    @launch_config.each { |key, value|
      @argv_string << "\"--#{key}=#{value}\", "
    }
    @argv_string << "]"
    @string_eval = ""
    @string_eval << "module "+ @name.capitalize + "\n"
    @string_eval << @argv_string
    @string_eval << File.open(@path).read
    @string_eval << "end # end of module " + @name
    @binding = eval("binding",TOPLEVEL_BINDING)
    eval(@string_eval,@binding,@path) # eval in an empty binding
  end
  
  def start_plug_fork()
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


      # http://ruby.about.com/od/advancedruby/a/The-Exec-Method.htm
      exec "#{@command_string}"
    }
    Process.detach(p) # otherwise p will be zombified by OS
    
  end
  

end
