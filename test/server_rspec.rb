require './server.rb'

def run_one_test(config_)
  server = Server.new("-f #{config_} -s")
  server.launch
  server.launched?.should eq(true)
end

describe Server, "#launch" do
  it "should launch with the default config file" do
    run_one_test("../config/default.yaml")
  end
  
  it "should launch without pathfinder (config 001.yaml)" do
    run_one_test("config/001.yaml")
  end
  
  it "should launch without export (config 002.yaml)" do
    run_one_test("config/002.yaml")
  end
  
  it "should launch without components (config 003.yaml)" do
    run_one_test("config/003.yaml")
  end
  
  it "should launch without mapping (config 004.yaml)" do
    run_one_test("config/004.yaml")
  end
  
  it "should launch with all components in fork (config 005.yaml)" do
    run_one_test("config/005.yaml")
  end
end
