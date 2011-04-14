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

class Plugin < Launcher
  
	if File.symlink?(__FILE__)
	  PATH =  File.dirname(File.readlink(__FILE__))
	else 
	  PATH = File.expand_path(File.dirname(__FILE__))
	end
  
  #1 Plugin definition in yaml config
  #2 Top reference
  def initialize(plugin_, top_) # Constructor
    @name   = plugin_["name"]
    @method = plugin_["method"]
    @path   = PATH + "/" + plugin_["exec"] 
    
    @launch_config = plugin_.dup
    @launch_config.delete("name")
    @launch_config.delete("method")
    @launch_config.delete("exec")
    super(@path, @method, @launch_config, top_)
    self.launch
  end
end
