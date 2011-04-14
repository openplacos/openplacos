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
      
      @config = config_
      @measure     = measure_
      @action_up   = config_["action+"]
      @action_down = config_["action-"]
      @is_regul_on = false
      @order       = nil
      @threshold = nil
      
      
      @regul_type = config_["type"] || autoSelectRegulType
        
      @frequency = config_["frequency"] || 1
      
      @hysteresis = config_["hysteresis"] || 1
	  
      Thread.current.abort_on_exception = true
      
      @thread = Thread.new{
        Thread.current.abort_on_exception = true
        loop do
          Thread.stop if !@is_regul_on
          sleep(@frequency)
          regul
        end
      }  

  end
  
  
  def regul
    # call the right methode according to the regul type
    self.method(@regul_type).call 
  end
  
  def set(option_)
    @threshold = option_["threshold"].to_f
    if !option_["hysteresis"].nil?
      @hysteresis = option_["hysteresis"]
    end
    if !option_["frequency"].nil?
      @frequency = option_["frequency"]
    end
    @is_regul_on = true
    if @thread.stop?
      @thread.wakeup
    end
  end
  
  def unset
    @is_regul_on = false
  end

  def state
    return @is_regul_on
  end
  
  def boolean_regul
    return if @threshold.nil?
    meas = @measure.get_value
    if meas > (@threshold + @hysteresis)
      if (not(@action_down.nil?) and (not(@measure.top.objects[@action_down].state["name"]=="on")))
        @measure.top.objects[@action_down].on 
      end
      if (not(@action_up.nil?) and (not(@measure.top.objects[@action_up].state["name"]=="off")))
        @measure.top.objects[@action_up].off
      end
    end
    if meas < (@threshold - @hysteresis)
      @measure.top.objects[@action_down].off if ( not(@action_down.nil?) and (not(@measure.top.objects[@action_down].state["name"]=="off")))
      @measure.top.objects[@action_up].on if ( not(@action_up.nil?) and (not(@measure.top.objects[@action_up].state["name"]=="on")))
    end
  end
  
  def pwm_regul
    return if @threshold.nil?
    meas = @measure.get_value
    error = (meas - @threshold)
    gain = 0.1
    previous_command = @measure.top.objects[@action_down].state['value'] || 0
    commande = previous_command + gain*error 
    if commande < 0
      commande = 0
    end
    if commande > 1
      commande =1
    end
     @measure.top.objects[@action_down].write(commande,{})    
  end

  def autoSelectRegulType
    #FIXME : Actuator are note yet create so it is impossible to detect the interface type
    #puts @measure.top.objects[@action_down].config["driver"]["interface"]
    type = :boolean_regul
    return type
  end

end
