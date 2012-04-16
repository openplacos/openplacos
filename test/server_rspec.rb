require './server.rb'

describe Server, "#launch" do
  it "should launch with the default config file" do
    server = Server.new("-f ../config/default.yaml -s")
    server.launch
    server.launched?.should eq(true)
  end
  
  it "should fail without pathfinder (config 001.yaml)" do
    server = Server.new("-f ./config/001.yaml -s")
    server.launch
    server.launched?.should eq(false)
  end
  
  it "should launch without export (config 002.yaml)" do
    server = Server.new("-f ./config/002.yaml -s")
    server.launch
    server.launched?.should eq(true)
  end
  
  it "should launch without components (config 003.yaml)" do
    server = Server.new("-f ./config/003.yaml -s")
    server.launch
    server.launched?.should eq(true)
  end
  
  it "should launch without mapping (config 004.yaml)" do
    server = Server.new("-f ./config/004.yaml -s")
    server.launch
    server.launched?.should eq(true)
  end
  
  it "should launch with all components in fork (config 005.yaml)" do
    server = Server.new("-f ./config/005.yaml -s")
    server.launch
    server.launched?.should eq(true)
  end
end
