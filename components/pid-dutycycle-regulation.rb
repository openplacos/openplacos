#!/usr/bin/env ruby 
# -*- coding: utf-8 -*-
require "rb-pid-controller"
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "This component is a PID regulator"
  c.version "0.1"
  c.default_name "pid-dutycycle-regulation"
  c.option :actuator , 'Kind of actuator (bool / boolinv (ie active low) / pwm )', :default => "pwm"
  c.option :frequency, 'Default frequency: bool period must be very low (> 10 min), pwm frequency can be high (< 1 sec)', :default => 1
  c.option :proportional, 'Proportional gain', :default => 0.01
  c.option :differential, 'Differential gain', :default => 0.005
  c.option :integrative, 'Integrative gain'  , :default => 0.005
  c.option :dividor, 'Gain dividor. Divide all gains by this factor since cant pass float'  , :default => 1
  c.option :initial_value, 'Set regulation active on start and set consign to this value'
  c.option :start_at_startup, 'Start regulation at startup', :default => false
end



class Regulation
  
  attr_accessor  :frequency, :threshold ,:hysteresis, :pidcontroller
  attr_reader :is_regul_on
  
  def initialize(type_,frequency_,sensor_,actuator_, kp_, ki_, kd_, dividor_)
      
    @is_regul_on  = false
    @threshold    = nil 
    @regul_type   = type_
    @frequency    = frequency_
    @hysteresis   = nil
    @sensor       = sensor_
    @actuator     = actuator_
    
    @kp = kp_/dividor_ # Proportional gain
    @ki = ki_/dividor_ # Integrative gain
    @kd = kd_/dividor_ # Derivative gain

    @command = 0

    # pid controller creation
    @pidcontroller = PIDController::PID.new(@kp,@ki,@kd, 5)

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
  
  def set
    @is_regul_on = true
    if @thread.stop?
      @thread.wakeup
    end
  end
  
  def unset
    @is_regul_on = false
    return LibComponent::ACK
  end
  
  def pid
    @command  =  @pidcontroller << read_sensor
    if @command > 1
      @command = 1
    end
    if @command < 0
      @command = 0
    end

  end

  # Boolean regulation :
  # Will work like PWM pid at very low frequency level
  def bool
    pid
    Thread.new{ # PWM emulator on bool actuator
      if (@command !=0)
        write_actuator(true)
        sleep([@command*@frequency, 1].max)
      end
      if (@command !=1)
        write_actuator(false)
      end
    }
  end
  
  def boolinv
    pid
    Thread.new{
      if (@command !=0)
        write_actuator(false)
        sleep([@command*@frequency, 1].max)
      end
      if (@command !=1)
        write_actuator(true)
      end
    }
  end  
  

  def pwm
    pid
    write_actuator(@command)    
  end

  private

  def read_sensor
    @sensor.read({})
  end
  
  def read_actuator
    @actuator.read({})
  end
  
  def write_actuator(value)
    @actuator.write(value,{}) if @actuator.read({}) != value
  end

end

case component.options[:actuator] 
  when "bool", "boolinv"
    component << actuator = LibComponent::Output.new("/actuator","digital.order.switch","rw")
  when "pwm"
    component << actuator = LibComponent::Output.new("/actuator","analog.order.dimmer","rw")
end

component << sensor    = LibComponent::Output.new("/sensor","analog","r")

component << switch    = LibComponent::Input.new("/regul","digital.regul.switch")
component << consign   = LibComponent::Input.new("/regul","analog.regul.consign")
component << frequency = LibComponent::Input.new("/regul","analog.regul.frequency")

regul = Regulation.new(component.options[:actuator], 
                       component.options[:frequency], 
                       sensor,
                       actuator, 
                       component.options[:proportional], 
                       component.options[:integrative], 
                       component.options[:differential], 
                       component.options[:dividor] )

regul.pidcontroller.set_consign(component.options[:initial_value] || 0)
if (component.options[:start_at_startup])
  regul.set
end

switch.on_write do |value, option|
  if value==1 or value==true
    regul.set
  elsif value==0 or value==false
    regul.unset
  end
  return LibComponent::ACK
end

switch.on_read do |option|
  regul.is_regul_on
end

consign.on_write do |value, option|
  regul.pidcontroller.set_consign(value)
  return LibComponent::ACK
end

consign.on_read do |option|
  regul.pidcontroller.consign
end

frequency.on_write do |value, option|
  regul.frequency = value
  return LibComponent::ACK
end

frequency.on_read do |option|
  regul.frequency
end
component.run
