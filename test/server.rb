require 'net/http'
require 'json'

class Server
  DAEMON_FILE = "#{File.dirname(__FILE__)}/../server/openplacos.pid"
  def initialize(str_)
    @arg = str_
    @status = false
  end 
  
  # Launch the server
  def launch
    while File.exist?(DAEMON_FILE)
      begin 
        Process.kill("INT",File.read(DAEMON_FILE).to_i)
      rescue
        raise "pid file is here but no process with this pid"
      end
      sleep 0.5 # maybee the deamon need mode time to quit
    end
    @status = system "#{File.dirname(__FILE__)}/../server/main.rb --daemon " + @arg 
    @status = wait_launch if @status==true
    return @status
  end
  
  # Kill the server
  def kill
    if File.exist?(DAEMON_FILE)
      Process.kill("INT",File.read(DAEMON_FILE).to_i)
    end
  end
  
  def get(url,params = {})
    uri = URI("http://localhost:4567#{url}")
    uri.query = URI.encode_www_form(params)
    JSON.parse Net::HTTP.get(uri)
  end
  
  def post(url,params)
    JSON.parse Net::HTTP.post_form(URI.parse("http://localhost:4567#{url}"),params).body
  end
  
  def ressources
    res = get('/ressources')
    ressources = Hash.new
    res.each do |res|
      ressources[res["name"]] = res
    end
    return ressources
  end
  
  private 
   # wait for the complete launch of the server
  def wait_launch
    begin
      url = URI.parse('http://localhost:4567')
      res = Net::HTTP.start(url.host, url.port) 
    rescue Errno::ECONNREFUSED
      sleep 1
      return false if !File.exist?(DAEMON_FILE) #Error after deamonize
      retry
    end
    return true
  end
  
end
