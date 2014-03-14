#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'open-uri'
require 'json'
require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "Controll mash steps"
  c.version "0.1"
  c.default_name "mashcontroller"
  c.option :recipe, 'Brewtoad URL', :default => "http://www.brewtoad.com/recipes/citra-double-ipa-6"
  c.option :tolerance, 'Temperature Step tolerance', :default => 1.0
  c.option :frequency, 'Default frequency', :default => 30

end

class MashController
  
  attr_accessor :is_on
  
  def initialize(steps_,temperature_,regulswitch_,regulconsign_,tolerance_,frequency_)
    # save inputs
    @steps = steps_
    @temperature = temperature_
    @switch = regulswitch_
    @consign = regulconsign_
    @tolerance = tolerance_
    @frequency = frequency_
    
    # parameters
    @is_on = false
    @current_step = 0
    @begin_step_time = nil
    
    #start thread
    @thread = Thread.new{
      Thread.current.abort_on_exception = true
      loop do
        Thread.stop if !@is_on
        controll
        sleep(@frequency)
      end
    }  
  end
  
  def controll
    @steps.each do |step|
    
      @current_step += 1
      
      # set consign
      @consign.write(step["target_temperature"],{})
      @switch.write(true,{})
      
      @begin_step_time = nil
      # wait until temperature is reached
      while @temperature.read({}).to_f < step["target_temperature"] - @tolerance
        sleep(@frequency)
      end
      
      @begin_step_time = Time.now
      # wait the end of step
      sleep(step["time"]*60)
    end
    @is_on = false
  end

  # start controll
  def start
    @is_on = true
    if @thread.stop?
      @thread.wakeup
    end
  end
  
  # stop controll
  def stop
    @is_on = false
    return LibComponent::ACK
  end

  def remaining_time
    if @begin_step_time.nil?
      remt = 0
    else
     remt = @steps[@current_step-1]["time"]*60 - (Time.now.to_i - @begin_step_time.to_i) 
    end
    return remt
  end
end

# Parce recipe
recipe  = JSON.parse(open(component.options[:recipe] + ".json").read)
steps = recipe["recipe_mash_steps"]
steps.sort_by! { |s| s["target_temperature"]}

# create Input and outputs
component << regulswitch = LibComponent::Output.new("/regul","digital.regul.switch","rw")
component << regulconsign = LibComponent::Output.new("/regul","analog.regul.consign","rw")
component << temperature = LibComponent::Output.new("/temperature","analog.sensor","r")

component << switch    = LibComponent::Input.new("/mash","digital.order.switch")
component << steptime  = LibComponent::Input.new("/mash","analog.time.second")

mash_controller = MashController.new(steps,temperature,regulswitch,regulconsign,component.options[:tolerance],component.options[:frequency])

switch.on_write do |value, option|
  if value==1 or value==true
    mash_controller.start
  elsif value==0 or value==false
    mash_controller.stop
  end
  return LibComponent::ACK
end

switch.on_read do |option|
  mash_controller.is_on
end

steptime.on_read do |option|
  mash_controller.remaining_time
end
component.run
