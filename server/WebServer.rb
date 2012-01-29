
class WebServer < Sinatra::Base

  enable :logging
  # set threaded option to true
  set :threaded, true
  
  get '/' do
    "Welcome to OpenplacOS"
  end
 
end

module WebServerHelpers

end
