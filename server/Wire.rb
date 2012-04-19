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

require 'globals.rb'
require 'Pin.rb'

class Wire
  attr_reader :pin0, :pin1, :iface0, :iface1

  def initialize(config_)
    @config     = config_
    @pin_name0  = @config.to_a[0][0]
    @pin_name1  = @config.to_a[0][1]
    @iface0     = ""
    @iface1     = ""
    if @pin_name0.include?('#')
      @pin_name0, @iface0 = @pin_name0.split('#')
    end
    if @pin_name1.include?('#')
      @pin_name1, @iface1 = @pin_name1.split('#')
    end
    @pin0       = nil
    @pin1       = nil
  end

  def push_pin(pin_)
    if    (pin_.dbus_name == @pin_name0)
      @pin0 = pin_
    elsif (pin_.dbus_name == @pin_name1)
      @pin1 = pin_
    end
  end

  def check_pins
    if @pin0.nil? 
      Globals.error("#{@pin_name0} not found")
    end
    if @pin1.nil? 
      Globals.error("#{@pin_name1} not found")
    end

    if @pin0.is_a?(Pin_input)
      if @pin1.is_a?(Pin_input)
        Globals.error("Mapping incorrect between #{@pin_name0} #{@pin_name1}")
      end
    end

    if @pin0.is_a?(Pin_output)
      if @pin1.is_a?(Pin_output)
        Globals.error("Mapping incorrect between #{@pin_name0} #{@pin_name1}")
      end
   end
  end
  
  

end
