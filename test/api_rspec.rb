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
    params = {"iface" => "analog.sensor.temperature.celcuis"}
    @server.get("/ressources/home/temperature",params)["value"].to_i.should eq(22)
  end
  
  it "light should be off" do
    params = {"iface" => "digital.order.switch"}
    @server.get("/ressources/home/light",params)["value"].should eq(false)
  end
  
  it "pwm fan should be 0" do
    params = {"iface" => "analog.order.dimmer"}
    @server.get("/ressources/home/fan",params)["value"].should eq(0.0)
  end
  
  it "write light should return 0" do
    params = {"iface" => "digital.order.switch", "value" => JSON.unparse([true])}
    @server.post("/ressources/home/light",params)["status"].should eq(0)
  end
   
  it "light should be on" do
    params = {"iface" => "digital.order.switch"}
    @server.get("/ressources/home/light",params)["value"].should eq(true)
  end
   
end


