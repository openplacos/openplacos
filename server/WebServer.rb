
module WebServerHelpers

end

class WebServer < Sinatra::Base
  enable :logging
  helpers ::WebServerHelpers
  
  get '/' do
    "Welcome to OpenplacOS"
  end

end

class ThinServer < Thin::Server

  def initialize(bind,port)
    super(bind,port, :signals => false) do
      use Rack::CommonLogger
      use Rack::ShowExceptions
      map "/" do
        run ::WebServer 
      end
    end  
  end

end
