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
require 'Launcher.rb'
require 'Pin.rb'
require 'globals'

class Component 
  include Launcher

  attr_accessor :inputs, :outputs, :name, :thread

  #1 Component definition in yaml config
  #2 Top reference
  def initialize(component_) # Constructor
        
    @config         = component_["config"] || Hash.new
    @name           = component_["name"]
    @config["name"] = @name
    @method         = component_["method"] || "thread"
    @inputs         = Array.new
                            @outputs        = Array.new
    @thread         = nil # Launcher attribute init
    @filename       = component_["exec"]
    @timeout        = component_["timeout"] || 30

    get_exec_path
    generate_command_string

  end

  def get_exec_path
    @exec           = @filename
    local_install   = File.dirname(__FILE__)
    local_file      = "#{local_install}/../components/#{@filename}"

    if    (File.exists?(local_file)) # installed in /components
      @exec = File.expand_path(local_file)
    elsif (File.exists?(@filename))  # abs_path to component
      @exec = File.expand_path(@filename)
    else
      Globals.error("#{@filename} not found", 144)
    end
  end

  def introspect
    @cache = Introspect.where(:command_string => @command_string ).first
    
    if ((!@cache.nil?) && @cache[:ttl_date] > DateTime.now )
      # cache hit
      @is_cached = true
      @introspect = YAML::load(@cache[:cached_data])
    else 
      # cache missed
      @is_cached = false
      @introspect_thread = Thread.new {
        @stout = launch_introspect
        @introspect = YAML::load( @stout)
      }
    end
  end

  def analyse
    if (!@introspect_thread.nil?) && @introspect_thread.join # wait for threaded introspect
      
      # Fill cache
      ttl = Time.now+ @introspect["component"]["ttl"]
      if @cache.nil? # first time
        Introspect.create({ :command_string => @command_string, 
                            :ttl_date       => ttl,
                            :cached_data    => @stout})
      else # update cache
        @cache[:ttl_date]    = ttl
        @cache[:cached_data] = @stout
        @cache.save
      end
    end

    if (!@introspect["input"].nil?) 
      if (! @introspect["input"]["pin"].nil?)
        @introspect["input"]["pin"].each_pair do |pin, ifaces| #pin level
          @inputs << Pin_input.new(pin, ifaces, self, @method)
        end
      end
    end

    if (!@introspect["output"].nil?) 
      if (! @introspect["output"]["pin"].nil?)
        @introspect["output"]["pin"].each_pair do |pin, ifaces| #pin level
          @outputs << Pin_output.new(pin, ifaces, self, @method)
        end
      end
    end

    @pins = @inputs + @outputs

  end

  def expose()
    @outputs.each do |pin|
      pin.expose_on_dbus()
    end    
  end

  def launch 
    launch_component()
  end

  def wait_for
    if(!(@method == "disable" || @method == "debug"))
      wait_for_component()
    end
  end
  
end
