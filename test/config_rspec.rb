require File.dirname(__FILE__)+'/server.rb'


def run_one_test(config_)
  server = Server.new("-f #{config_} -s -l #{File.dirname(__FILE__)}/opos.log")
  status = server.launch
  status.should eq(true)
  server.kill
end

describe Server, "#config" do
  it "should launch with the default config file" do
    run_one_test(File.dirname(__FILE__)+"/../config/default.yaml")
  end
  
  it "should launch without pathfinder (config 001.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/001.yaml")
  end
  
  it "should launch without export (config 002.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/002.yaml")
  end
  
  it "should launch without components (config 003.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/003.yaml")
  end
  
  it "should launch without mapping (config 004.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/004.yaml")
  end
  
  it "should launch with all components in fork (config 005.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/005.yaml")
  end
end
