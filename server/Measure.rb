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


  def initialize(name_, top_, path_dbus_, interface_, object_list_, dependencies_) # Constructor

    # Class variables
    @name = name_
    @path_dbus = path_dbus_
    @object_list = object_list_
    @interface = interface_
    @dependencies = dependencies_
    @top = top_

    # Open a Dbus socket
    @driver = Bus.service(@path_dbus)
    @object_list.each do |obj|
      @object = @driver.object(obj)
    end
  end

  def check(overpass_, ttl_)
    if (@lock==1 && overpass==0)
      puts "Dependencies loop for @name measure"
      assert 0
    end
    if (ttl_ == 0)
      return
    end
    if (@dependencies != nil)
        @dependencies.each { |dep|
          @top.measure["dep"].check(0, ttl_ - 1)
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
