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
require 'Dbus_proxy_fork'
require 'Dbus_proxy_thread'


module Launcher

  def launch_introspect()
    return `#{@command_string} --introspect `
  end

  def launch_component() # TODO TODO TODO launch_component in a thread/fork module TODO TODO TODO
    if (@method == "debug")
      puts @command_string
      return
    end
    if (@method != "disable")  #do nothing
      if (@method == "thread")  #launch in thread mode
        if @thread.nil? #check if thread has been already launched
          @thread = start_thread()
        else # if thread has been launch, you attempt to relaunch
          if @thread.alive? #check if thread are running (or sleeping)
            # Alive thread relaunch id forbiden
            @top.dbus_plugins.error("Attempt to relaunch a alive thread : #{@exec} | it's forbiden",{})
            raise "Attempt to relaunch a alive thread : #{@exec} | it's forbiden"
          else 
            #relaunch the thread
            @thread = start_thread()
          end 
        end 
      else 
        start_fork()
      end 
    end 
  end 

  def generate_command_string
    @command_string = "#{@exec}"
    if  !@config.nil?
      @config.each { |key, value|
        @command_string << " --#{key}=#{value}"
      }
    end
  end
  
  private

  def start_thread()
    self.instance_eval("self.extend(Dbus_proxy_thread)")
    th = Thread.new{
      @argv_string = "ARGV = ["
      if  !@config.nil?
        @config.each { |key, value|
          @argv_string << "\"--#{key}=#{value}\", "
        }
      end
      @argv_string << "]\n"
      @string_eval = ""
      @string_eval << "module "+ @name.capitalize + "\n"
      @string_eval << ""
      @string_eval << @argv_string
      @string_eval << File.open(@exec).read
      @string_eval << "end # end of module " + @name
      @binding = eval("binding",TOPLEVEL_BINDING)
      eval(@string_eval,@binding,@exec) # eval in an empty binding
    }
    return th
  end
  
  def start_fork()
    self.instance_eval("self.extend(Dbus_proxy_fork)")
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
