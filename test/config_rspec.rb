require File.dirname(__FILE__)+'/server.rb'


def run_one_test(config_)
  server = Server.new("-f #{config_} -l #{File.dirname(__FILE__)}/opos.log")
  status = server.launch
  server.kill
  return status
end

def kill_server
    if File.exist?("#{File.dirname(__FILE__)}/../server/openplacos.pid")
      Process.kill("INT",File.read("#{File.dirname(__FILE__)}/../server/openplacos.pid").to_i)
    end
    sleep 0.5 # wait the server is down
end

describe Server, "#config" do

  after(:each) do
    kill_server
  end
  
  after(:all) do
    kill_server
  end
  
  # true means server should launch
  # false means server shouldn't launch

  it "should launch with the default config file" do
    run_one_test(File.dirname(__FILE__)+"/../config/default.yaml").should eq(true)
  end
  
  it "should launch without pathfinder (config 001.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/001.yaml").should eq(true)
  end
  
  it "should launch without export (config 002.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/002.yaml").should eq(true)
  end
  
  it "should launch with all components in fork (config 005.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/005.yaml").should eq(true)
  end
  
  it "shouldn't launch with an iface indetermination (config 006.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/006.yaml").should eq(false)
  end
  
  it "shouldn't launch with ifaces doesnt match (config 007.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/007.yaml").should eq(false)
  end

  it "shouldn't launch with wrong map name (config 008.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/008.yaml").should eq(false)
  end
  
  it "shouldn't launch with wrong iface name (config 009.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/009.yaml").should eq(false)
  end

  it "shouldn't launch with incorrect mapping : 2 output (config 010.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/010.yaml").should eq(false)
  end

  it "shouldn't launch with incorrect mapping : 2 input (config 011.yaml)" do
    run_one_test(File.dirname(__FILE__)+"/config/011.yaml").should eq(false)
  end

  it "should launch in debug mode" do
    run_one_test(File.dirname(__FILE__)+"/config/012.yaml").should eq(true)
  end
 
  it "should not launch if an exported object is not mapped" do
    run_one_test(File.dirname(__FILE__)+"/config/013.yaml").should eq(false)
  end
 
end

