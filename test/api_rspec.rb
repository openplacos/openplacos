require 'yaml'
require File.dirname(__FILE__)+'/server.rb'

CONFIG_FILE =  File.dirname(__FILE__)+"/../config/default.yaml"

describe Server, "#api" do
  
  before(:all) do
    @server = Server.new("-f #{CONFIG_FILE} ")
    @server.launch
    @config = YAML::load(File.read(CONFIG_FILE))
  end
  
  after(:all) do
    @server.kill
  end
  
  it "ressources names should equal to thoses declared in config file" do
    @server.ressources.keys.should eq(@config["export"])
  end
  
  it "temperature should equal to 22" do
    @server.get("/ressources/home/temperature?iface=analog.sensor.temperature.celcuis")["value"].to_i.should eq(22)
  end
  
  it "light should be off" do
    @server.get("/ressources/home/light?iface=digital.order.switch")["value"].should eq(false)
  end
  
  it "pwm fan should be 0" do
    @server.get("/ressources/home/fan?iface=analog.order.dimmer")["value"].should eq(0.0)
  end
   
end


