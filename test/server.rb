require 'net/http'
require 'json'

class Server
  DAEMON_FILE = "#{File.dirname(__FILE__)}/../server/opos-daemon.pid"
  def initialize(str_)
    @arg = str_
    @status = false
  end 
  
  # Launch the server
  def launch
    @status = system "#{File.dirname(__FILE__)}/../server/main.rb --deamon " + @arg 
    wait_launch if @status==true
    return @status
  end
  
  # Kill the server
  def kill
    if File.exist?(DAEMON_FILE)
      Process.kill("INT",File.read(DAEMON_FILE).to_i)
    end
  end
  
  def get(url)
    JSON.parse Net::HTTP.get(URI.parse("http://localhost:4567#{url}"))
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
      retry
    end
    return true
  end
  
end
