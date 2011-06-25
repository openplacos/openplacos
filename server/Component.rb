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

class Component  < Launcher

  #1 Component definition in yaml config
  #2 Top reference
  def initialize(component_) # Constructor
    @name   = component_["name"]
    @method = component_["method"]
    @exec   = component_["exec"] 
  end

  def introspect
    @introspect_thread = Thread.new {
    stout = launch_introspect
    @introspect = YAML::load( stout)
    }
  end

  def expose(service_)
    @introspect_thread.join
    puts "#{@name} introspect:"
    puts @introspect.inspect
    puts ""
  end


end
