require 'yaml'
require "mkfifo"

require File.dirname(__FILE__)+'/server.rb'

describe Server, "#arduino" do
  
  before(:all) do
    File.mkfifo('/tmp/arduino_in')
    File.mkfifo('/tmp/arduino_out')
    system(File.dirname(__FILE__)+"/arduino_emulator.rb &")
    @config = "#{File.dirname(__FILE__)}/config/arduino.yaml"
    @server = Server.new("-f #{@config}")
    @server.launch
    @config = YAML::load(File.read(@config))
  end
  
  after(:all) do
    File.delete('/tmp/arduino_in')
    File.delete('/tmp/arduino_out')
    @server.kill
  end
  
  it "read digital on arduino" do
    params = {"iface" => "digital"}
    @server.get("/ressources/home/light",params)["value"].to_i.should eq(1)
  end
  
  it "read analog on arduino" do
    params = {"iface" => "analog"}
    @server.get("/ressources/home/temperature",params)["value"].to_f.round(2).should eq(2.99)
  end
  
 
end


