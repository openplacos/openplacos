require 'net/http'
require 'uri'
class Server
  def initialize(str_)
    @arg = str_
    @status = false
  end 
  
  #launch the server
  def launch
    @th = Thread.new do
      @status = system "../server/main.rb " + @arg 
    end
  end
  
  # check if the server is launched by trying to connect
  def launched?
    th = Thread.new do
      begin
        url = URI.parse('http://localhost:4567')
        res = Net::HTTP.start(url.host, url.port) 
        system "pkill main.rb"        
      rescue Errno::ECONNREFUSED
        sleep 1
        retry
      end
    end
    @th.join
    return @status
  end
end
