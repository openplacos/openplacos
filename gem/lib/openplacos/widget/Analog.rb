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
  module Analog
    def to_s
      read({})[0].round(2).to_s
    end

    def render
      return to_s
    end

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

