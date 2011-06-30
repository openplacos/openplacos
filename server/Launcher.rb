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

module Launcher

  def launch_introspect()
    return `#{@exec} --introspect`
  end

  def launch_component() 
    if (@method != "disable")  #do nothing
      if (@method == "thread")  #launch in thread mode
        if @thread.nil? #check if thread has been already launched
          @thread = Thread.new{
            start_thread()
          }
        else # if thread has been launch, you attempt to relaunch
          if @thread.alive? #check if thread are running (or sleeping)
            # Alive thread relaunch id forbiden
            @top.dbus_plugins.error("Attempt to relaunch a alive thread : #{@exec} | it's forbiden",{})
            raise "Attempt to relaunch a alive thread : #{@exec} | it's forbiden"
          else 
            #relaunch the thread
            @thread = Thread.new{
              start_thread()
            }
          end 
        end 
      else 
        start_fork()
      end 
    end 
  end 
  
  private

  def start_thread()
    puts "******* coucou"
    @argv_string = "ARGV = ["
 
    @argv_string << "]"
    @string_eval = ""
    @string_eval << "module "+ @name.capitalize + "\n"
    @string_eval << @argv_string
    @string_eval << File.open(@exec).read
    @string_eval << "end # end of module " + @name
    @binding = eval("binding",TOPLEVEL_BINDING)
    eval(@string_eval,@binding,@exec) # eval in an empty binding
  end
  
  def start_fork()
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
