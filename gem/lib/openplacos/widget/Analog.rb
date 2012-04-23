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
#    GNU General Public License for more details.s.instance
#
#    You should have received a copy of the GNU General Public License
#    along with Openplacos.  If not, see <http://www.gnu.org/licenses/>.


module Openplacos

  # Namespace for Analog signals.
  module Analog

    # convert an analog value to a string
    # supposed to be generic to all clients
    # can be easily overloaded if needed
    def to_s
      read({}).round(2).to_s
    end

    # render method is supposed to be overlaoded
    # this method is like a view 
    # this method returns a string formatted as needed for the client to express an analog value
    def render
      return to_s
    end

  end
  
  module Analog::Order
    include Analog

    def set(arg_)
     write(arg_.to_f, {})
    end
  end
  
  module Analog::Regul
    include Analog::Order
  end

  module  Analog::Sensor
    include Analog

    def render
      return to_s + " " + unit
    end

    def unit
      @name.split(".").last
    end

  end
end

