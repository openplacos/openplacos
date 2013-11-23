#!/usr/bin/env ruby 
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "This component is a PID regulator"
  c.version "0.1"
  c.default_name "pidchauffage"
  c.option :actuator , 'Kind of actuator (bool / boolinv (ie active low) / pwm / pwminv)', :default => "pwminv"
  c.option :frequency, 'Default frequency: bool period must be very low (> 10 min), pwm frequency can be high (< 1 sec)', :default => 10
  c.option :proportional, 'Proportional gain', :default => 0.3
  c.option :differential, 'Differential gain', :default => 10.0
  c.option :integrative, 'Integrative gain'  , :default => 0.00001
end

module PIDController

  class PID

    attr_accessor :kp, :ki, :kd, :consign
    
    def initialize(kp = 1 ,ki = 1,kd = 1, history_depth_=-1)
      # save pid coefficient
      @kp            = kp.to_f
      @ki            = ki.to_f
      @kd            = kd.to_f
      @history_depth = history_depth_
      @consign       = nil
      @history       = Array.new

      self.reset 
      
    end
    
    #Public methods
    public
    
    def set_consign(consign)
      @consign = consign.to_f
    end
    
    def <<(value)
      e,dt = error(value)

      out = proportional(e) + integrative(e,dt) + derivative(e,dt)
      @previous_error = e
      
      return out
    end
    
    def reset
      @previous_error = 0.0
      @integrative = 0.0
      @last_time = nil
    end
    
    #Private methods
    private 
    
    def error(value)
      out = @consign -value
      
      t = Time.now.to_i
      if @last_time.nil?
        dt = 1.0
      else
        dt = (t - @last_time).to_f
      end
      @last_time = t
      return out,dt
    end
    
    # compute the proportional term
    def proportional(error)
      return @kp*error
    end
    
    # compute the derivative term
    def derivative(error,dt)
      return @kd*(error - @previous_error)/dt
    end
    
    # compute the integrative term
    def integrative(error,dt)
      # classic mode
      @integrative = @integrative + error*dt

      # window mode
      if(@history_depth != -1)
        @history << error*dt                     # push last sample
        @history = @history.last(@history_depth) # keep the last one
        @integrative =  0
        @history.each { |e|
          @integrative +=e
        }
        @integrative /= @history_depth          # normalize
      end

      return @ki*@integrative
    end
    


  end

  class PD < PID
    def initialize(kp,kd)
      super(kp,0,kd)
    end
  end

  class PI < PID
    def initialize(kp,ki)
      super(kp,ki,0)
    end
  end

end


class Regulation
  
  attr_accessor  :frequency, :threshold ,:hysteresis, :pidcontroller
  attr_reader :is_regul_on
  
  def initialize(type_,frequency_,sensor_,actuator_, kp_, ki_, kd_)
      
    @is_regul_on  = false
    @threshold    = nil 
    @regul_type   = type_
    @frequency    = frequency_
    @hysteresis   = nil
    @sensor       = sensor_
    @actuator     = actuator_
    
    @kp = kp_ # Proportional gain
    @ki = ki_ # Integrative gain
    @kd = kd_ # Derivative gain

    @command = 0

    # pid controller creation
    @pidcontroller = PIDController::PID.new(@kp,@ki,@kd)

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
  end

  def pwminv
    pid
    puts @command
    if @command > 1
      @command = 1
    end
    if @command < 0
      @command = 0
    end
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
    puts "write: " + value.to_s
    @actuator.write(value,{}) if @actuator.read({}) != value
  end

end

component << actuator = LibComponent::Output.new("/actuator","analog.order.dimmer","rw")


component << sensor    = LibComponent::Output.new("/sensor","analog","r")

component << switch    = LibComponent::Input.new("/regul","digital.regul.switch")
component << consign   = LibComponent::Input.new("/regul","analog.regul.consign")
component << frequency = LibComponent::Input.new("/regul","analog.regul.frequency")

regul = Regulation.new(component.options[:actuator], component.options[:frequency], sensor,actuator, component.options[:proportional], component.options[:integrative], component.options[:differential] )
regul.pidcontroller.set_consign(0)

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
