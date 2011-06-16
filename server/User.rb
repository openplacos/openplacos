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

class User
  attr_reader :login, :hash ,:permissions
  def initialize(cfg_,top_)
    @login = cfg_["login"]
    @hash = cfg_["hash"]
    
    @permissions = Hash.new
    
    #set read permission
    @permissions["read"] = Array.new
    
    if cfg_["permissions"]["read"]
      cfg_["permissions"]["read"].split(",").each { |item|
        @permissions["read"].push(top_.objects.keys) if item == "all"
        @permissions["read"].push(top_.measures.keys) if item == "measures"
        @permissions["read"].push(top_.actuators.keys) if item == "actuators"
        @permissions["read"].push(item) if (top_.actuators.keys.include?(item) or top_.measures.keys.include?(item))
      }
    end
    
    @permissions["read"].flatten! 
    @permissions["read"].uniq! # remove similar keys
    
    #set write permission
    @permissions["write"] = Array.new
    
    if cfg_["permissions"]["write"]
      cfg_["permissions"]["write"].split(",").each { |item|
        @permissions["write"].push(top_.objects.keys) if item == "all"
        @permissions["write"].push(top_.measures.keys) if item == "measures"
        @permissions["write"].push(top_.actuators.keys) if item == "actuators"
        @permissions["write"].push(item) if (top_.actuators.keys.include?(item) or top_.measures.keys.include?(item))
      }
    end
    
    @permissions["write"].flatten!
    @permissions["write"].uniq!
    
    #remove exclude
    if cfg_["permissions"]["exclude"]
      cfg_["permissions"]["exclude"].split(",").each { |item|
        @permissions["read"].delete(item)
        @permissions["write"].delete(item)
      }
    end
  
    if cfg_["permissions"]["include"]
      cfg_["permissions"]["include"].split(",").each { |item|
        @permissions["read"].push(item)
        @permissions["write"].push(item)
      }
    end
    
    
  end

end
