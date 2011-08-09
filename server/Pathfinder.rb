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

require 'file/find' # http://rubygems.org/gems/file-find
require 'globals.rb'

class Pathfinder
  include Singleton

  def init_pathfinder(config_)  # act as a contructor, give me a config !
    @config = config_
  end


  def get_file(name_)
    rule = File::Find.new(
                          :name     => name_,
                          :follow   => false,
                          :path     => @config,
                          # :maxdepth => 4 # https://github.com/djberg96/file-find/issues/2
                          )
    if (rule.find.empty?)
      Globals.error("#{name_} not found -- please check config")
    end
    return File.expand_path(rule.find.first) # consider only first one
  end

end
