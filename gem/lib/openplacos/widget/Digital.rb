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
  module Digital
    def to_s
      read({})
    end

    def render
      return to_s
    end


    module Order
      include Digital

      module Switch
        include Order

        def set(arg_)
          if (arg_ == "True" || (arg_ == "true") || (arg_ == "on")|| (arg_ == "ON"))
            return write(true, {})
          end
          if (arg_ == "False" || (arg_ == "false")|| (arg_ == "off")|| (arg_ == "OFF"))
            return write(false, {})
          end
          puts "Action not recognized, please use ON/OFF"
        end
      end

    end

  end
end
