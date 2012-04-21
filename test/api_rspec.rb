require 'yaml'
require './server.rb'

CONFIG_FILE =  File.dirname(__FILE__)+"/../config/default.yaml"

describe Server, "#api" do
  
  before(:all) do
    @server = Server.new("-f #{CONFIG_FILE} -s")
    @server.launch
    @server.wait_launch
    
    @config = YAML::load(File.read(CONFIG_FILE))
  end
  
  it "ressources names should equal to thoses declared in config file" do
    @server.ressources.keys.should eq(@config["export"])
  end
  
  after(:all) do
    @server.kill
  end
  
end


