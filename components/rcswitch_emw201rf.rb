#!/usr/bin/ruby 
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "For emw201rf of EverFlourish switch controler by PT2262"
  c.version "0.1"
  c.default_name "rcswitch"
end

module Switch
  
  def set_code(group_, switch_)
    group  = "FFF".insert(group_, '0')
    switch = "FF".insert(switch_-1, '0')
    @ThreeStateCode = group + switch    
  end
  
  def on
    return Transmitter.write("#{@ThreeStateCode}FFFF1",{})
  end
  
  def off
    return Transmitter.write("#{@ThreeStateCode}FFFF0",{})
  end
  
  def write(value, option)
    if value==1 or value==true
      @state = true
      return self.on
    elsif value==0 or value==false
      @state = false
      return self.off
    end
  end

  def read(options_)
    return @state || false
  end

end

component << Transmitter = LibComponent::Output.new("/transmitter","pt2262","w")
component << SwitchA1 = LibComponent::Input.new("/groupA/switch1","digital.order.switch").extend(Switch)
component << SwitchA2 = LibComponent::Input.new("/groupA/switch2","digital.order.switch").extend(Switch)
component << SwitchA3 = LibComponent::Input.new("/groupA/switch3","digital.order.switch").extend(Switch)
component << SwitchB1 = LibComponent::Input.new("/groupB/switch1","digital.order.switch").extend(Switch)
component << SwitchB2 = LibComponent::Input.new("/groupB/switch2","digital.order.switch").extend(Switch)
component << SwitchB3 = LibComponent::Input.new("/groupB/switch3","digital.order.switch").extend(Switch)
component << SwitchC1 = LibComponent::Input.new("/groupC/switch1","digital.order.switch").extend(Switch)
component << SwitchC2 = LibComponent::Input.new("/groupC/switch2","digital.order.switch").extend(Switch)
component << SwitchC3 = LibComponent::Input.new("/groupC/switch3","digital.order.switch").extend(Switch)
component << SwitchD1 = LibComponent::Input.new("/groupD/switch1","digital.order.switch").extend(Switch)
component << SwitchD2 = LibComponent::Input.new("/groupD/switch2","digital.order.switch").extend(Switch)
component << SwitchD3 = LibComponent::Input.new("/groupD/switch3","digital.order.switch").extend(Switch)


SwitchA1.set_code(0,0)
SwitchA2.set_code(0,2)
SwitchA3.set_code(0,3)
SwitchB1.set_code(1,0)
SwitchB2.set_code(1,2)
SwitchB3.set_code(1,3)
SwitchC1.set_code(2,0)
SwitchC2.set_code(2,2)
SwitchC3.set_code(2,3)
SwitchD1.set_code(3,0)
SwitchD2.set_code(3,2)
SwitchD3.set_code(3,3)

component.run
