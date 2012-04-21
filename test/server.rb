require 'net/http'
require 'json'

class Server
  def initialize(str_)
    @arg = str_
    @status = false
  end 
  
  # Launch the server
  def launch
    @th = Thread.new do
      
      @status = system "#{File.dirname(__FILE__)}/../server/main.rb " + @arg 
    end
  end
  
  # Kill the server
  def kill
    system "pkill main.rb"        
  end
  
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

  # check if the server is launched by trying to connect and kill it
  def launched?
    th = Thread.new do
      wait_launch
      kill
    end
    @th.join
    return @status
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
  
end
