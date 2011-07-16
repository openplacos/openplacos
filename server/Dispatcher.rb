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

require 'Map.rb'

class Dispatcher
  include Singleton

  def init_dispatcher # act as a constructor
    @maps = Array.new
    @pins = Array.new
  end
  
  def add_map(map_config_)
    @maps << Map.new(map_config_)
  end
  
  def register_pin(pin_)
    @pins << pin_
  end
  
  def push_pin (pin_)
    @maps.each do |map|
      map.push_pin(pin_) # Maybe pin_ is part of map
    end
  end

  def check_all_pin # Check that every Map has to 2 pins
     @maps.each do |map|
      map.check_pins
    end
  end

end

