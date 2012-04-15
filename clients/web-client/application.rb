class WebClient < Sinatra::Base
  helpers Sinatra::ContentFor
  
  # sinatra configuration
  set :static, true
  set :public_forder, settings.root + '/public'
  set :views,  settings.root + '/views'
  set :haml, :format => :html5
  
  enable :sessions
  enable :logging
  
  get '/' do
  
    content_for :menu_left do
      "salut"
    end
    
    content_for :menu_top do
      haml :menu_top
    end
    
    haml :home
  end

end

