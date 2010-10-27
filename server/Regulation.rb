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

class Regulation
  
  attr_reader :action_down, :action_up
  
  def initialize(config_,measure_)
      
      @measure     = measure_
      @action_up   = config_["action+"]
      @action_down = config_["action-"]
      @is_regul_on = false
      @order       = nil
      @threeshold = nil
      if config_["frequency"].nil?
		@frequency = 1 #by default 
	  else
	    @frequency = config_["frequency"]
	  end
	  
	  if config_["hysteresis"].nil?
		@hysteresis = 1 #by default 
	  else
	    @hysteresis = config_["hysteresis"]
	  end
	  
      Thread.abort_on_exception = true
      
      @thread = Thread.new{
        loop do
          Thread.stop if !@is_regul_on
          sleep(@frequency)
          regul
        end
      }  

  end
  
  
  def regul
    return if @threeshold.nil?
    meas = @measure.get_value
    if meas > (@threeshold + @hysteresis)
      if (not(@action_down.nil?) and (not(@measure.top.objects[@action_down].state["name"]=="on")))
        @measure.top.objects[@action_down].on 
      end
      if (not(@action_up.nil?) and (not(@measure.top.objects[@action_up].state["name"]=="off")))
        @measure.top.objects[@action_up].off
      end
    end
    if meas < (@threeshold - @hysteresis)
      @measure.top.objects[@action_down].off if ( not(@action_down.nil?) and (not(@measure.top.objects[@action_down].state["name"]=="off")))
      @measure.top.objects[@action_up].on if ( not(@action_up.nil?) and (not(@measure.top.objects[@action_up].state["name"]=="on")))
    end
    
  end
  
  def set(option_)
    @threeshold = option_["threeshold"]
    if !option_["hysteresis"].nil?
      @hysteresis = option_["hysteresis"]
    end
    @is_regul_on = true
    @thread.wakeup
  end
  
  def unset
    @is_regul_on = false
  end

end
