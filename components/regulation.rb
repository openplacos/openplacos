#!/usr/bin/env ruby 
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "This is openplacos component for regulation"
  c.version "0.1"
  c.default_name "regulation"
  c.option :type , 'Kind of regulation (bool / boolinv / pwm / pid)', :default => "bool"
  c.option :frequency, 'Default frequency', :default => 1
  c.option :threshold, 'Default threshold', :default => 0 
end



class Regulation
  
  attr_accessor  :frequency, :threshold ,:hysteresis
  attr_reader :is_regul_on
  
  def initialize(type_,frequency_,sensor_,actuator_)
      
      @is_regul_on  = false
      @threshold    = nil 
      @regul_type   = type_
      @frequency    = frequency_
      @hysteresis   = nil
      @sensor       = sensor_
      @actuator     = actuator_

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
    define_hysteresis_from_measure if @hysteresis.nil?
    define_threshold_from_measure if @threshold.nil?

    @is_regul_on = true
    if @thread.stop?
      @thread.wakeup
    end
  end
  
  def unset
    @is_regul_on = false
    return LibComponent::ACK
  end
  
  # Boolean regulation :
  # * Switch off the actuator if the measure of the is greater than the threshold + hysteresys
  # * Switch on the actuator if the measure of the is lower than the threshold - hysteresys
  def bool
    meas = read_sensor
    if meas > (@threshold + @hysteresis)
      write_actuator(true)
    end
    if meas < (@threshold - @hysteresis)
      write_actuator(false)
    end
  end
  
  # Inverse boolean regulation :
  # * Switch off the actuator if the measure of the is greater than the threshold + hysteresys
  # * Switch on the actuator if the measure of the is lower than the threshold - hysteresys
  def boolinv
    meas = read_sensor
    if meas > (@threshold + @hysteresis)
      write_actuator(false)
    end
    if meas < (@threshold - @hysteresis)
      write_actuator(true)
    end
  end  
  
  def pwm
    meas = read_sensor
    error = (meas - @threshold)
    gain = 0.1
    previous_command = read_actuator || 0
    commande = previous_command + gain*error 
    if commande < 0
      commande = 0
    end
    if commande > 1
      commande = 1
    end
    write_actuator(commande)    
  end
  
  # Set the threshold to the current value of the sensor
  def define_threshold_from_measure
    @threshold = read_sensor
  end
  
  # Set the hysteresis to 10% of the current value of the sensor
  def define_hysteresis_from_measure
    @hysteresis = read_sensor*0.1 # 10% of the measure
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

case component.options[:type] 
  when "bool", "boolinv"
    component << actuator = LibComponent::Output.new("/actuator","digital.order.switch","rw")
    component << Hysteresis = LibComponent::Input.new("/regul","analog.regul.hysteresis")
    
    Hysteresis.on_write do |value, option|
      Regul.hysteresis = value
      return LibComponent::ACK
    end

    Hysteresis.on_read do |option|
      Regul.hysteresis || Regul.define_hysteresis_from_measure
    end
  when "pwm"
    component << actuator = LibComponent::Output.new("/actuator","analog.order.dimmer","rw")
end

component << sensor = LibComponent::Output.new("/sensor","analog","r")

component << Switch = LibComponent::Input.new("/regul","digital.regul.switch")
component << Threshold = LibComponent::Input.new("/regul","analog.regul.threshold")
component << Frequency = LibComponent::Input.new("/regul","analog.regul.frequency")

Regul = Regulation.new(component.options[:type], component.options[:frequency], sensor,actuator)

Switch.on_write do |value, option|
  if value==1 or value==true
    Regul.set
  elsif value==0 or value==false
    Regul.unset
  end
  return LibComponent::ACK
end

Switch.on_read do |option|
  Regul.is_regul_on
end

Threshold.on_write do |value, option|
  Regul.threshold = value
  return LibComponent::ACK
end

Threshold.on_read do |option|
  Regul.threshold || Regul.define_threshold_from_measure
end

Frequency.on_write do |value, option|
  Regul.frequency = value
  return LibComponent::ACK
end

Frequency.on_read do |option|
  Regul.frequency
end

component.run
