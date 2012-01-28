require "sinatra/base"
require "thin"

class WebServer < Sinatra::Base

  # set threaded option to true
  set :threaded, true
  
  get '/' do
    "Welcome to OpenplacOS"
  end

end

