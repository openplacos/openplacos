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
      cfg_["permissions"]["read"].split(";").each { |item|
        #parse shortcut
        @permissions["read"].push(top_.objects.keys) if item == "all"
        @permissions["read"].push(top_.measures.keys) if item == "measures"
        @permissions["read"].push(top_.actuators.keys) if item == "actuators"
        #parse other keys
        if (top_.actuators.keys.include?(item) or top_.measures.keys.include?(item))
          #parse objects path name
          @permissions["read"].push(item) 
        else
          #parse room names
          allkey = (top_.actuators.keys.dup << top_.measures.keys.dup).flatten
          allkey.each { |key|
            @permissions["read"] << key if key.match(item)
          }
        end
      }
    end
    
    #set write permission
    @permissions["write"] = Array.new
    
    if cfg_["permissions"]["write"]
      cfg_["permissions"]["write"].split(";").each { |item|
        @permissions["write"].push(top_.objects.keys) if item == "all"
        @permissions["write"].push(top_.measures.keys) if item == "measures"
        @permissions["write"].push(top_.actuators.keys) if item == "actuators"
        #parse other keys
        if (top_.actuators.keys.include?(item) or top_.measures.keys.include?(item))
          #parse objects path name
          @permissions["write"].push(item) 
        else
          #parse room names
          allkey = (top_.actuators.keys.dup << top_.measures.keys.dup).flatten
          allkey.each { |key|
            @permissions["write"] << key if key.match(item)
          }
        end      
        }
    end
    
    @permissions["write"].flatten!
    @permissions["write"].uniq!
    
    #write seed in 
    @permissions["read"] << @permissions["write"]
      
    @permissions["read"].flatten! 
    @permissions["read"].uniq! # remove similar keys
    
    #remove exclude
    if cfg_["permissions"]["exclude"]
      cfg_["permissions"]["exclude"].split(";").each { |item|
        if (top_.actuators.keys.include?(item) or top_.measures.keys.include?(item))
          #parse objects path name
          @permissions["write"].delete(item) 
          @permissions["read"].delete(item) 
        else
          #parse room names
          allkey = (top_.actuators.keys.dup << top_.measures.keys.dup).flatten
          allkey.each { |key|
            if key.match(item)
              @permissions["write"].delete(key) 
              @permissions["read"].delete(key)
            end
          }
        end   
      }
    end
    
  end

end
