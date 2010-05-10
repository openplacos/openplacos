#/usr/bin/ruby -w

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

require 'dbus'
include REXML

class Measure


  def initialize(meas_, top_) # Constructor

    # Class variables
    @name = meas_["name"]
    @path_dbus = meas_["driver"]
    @object_list = meas_["object"]
    @interface = meas_["interface"]
    @dependencies = meas_["dep_list"]
    @top = top_

    # Open a Dbus socket
    @driver = Bus.service(@path_dbus)
    @object_list.each do |obj|
      @object = @driver.object(obj)
    end
  end

  def check(overpass_, ttl_)
    if (@check_lock==1 && overpass_==0)
      puts "\nDependencies loop detected for " + @name + " measure !"
      puts "Please check dependencies for this measure"
      Process.exit
    end
    if (ttl_ == 0)
      return
    end
    if (@dependencies != nil)
        @dependencies.each { |dep|
          @top.measure[dep].check(0, ttl_ - 1)
        }
      end
    return 
  end

  def sanity_check()
    @check_lock = 1
    # Check overpass for first time
    self.check(1, @top.measure.length())
     @check_lock = 0
  end

end
