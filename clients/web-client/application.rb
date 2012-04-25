

class WebClient < Sinatra::Base

  CLIENT_ID = '7olsiabevyxnp7c33crmrkbqb'
  CLIENT_SECRET = 'c04d6719rqwkuy0o7juicudr5'
  REDIRECT_URI = 'http://localhost:9292/oauth2/callback'
  DEFAULT_OPTS = {:mode=>:header, :header_format=>"OAuth %s", :param_name=>"oauth_token"}
  SITE_URL = 'http://localhost:4567'

  Client = OAuth2::Client.new(CLIENT_ID,CLIENT_SECRET, {:site => SITE_URL, :token_url => '/oauth/authorize'})

  Token = Hash.new

  helpers Sinatra::ContentFor
  # sinatra configuration
  set :static, true
  set :public_forder, File.join(File.dirname(__FILE__),'public')
  set :views,  File.join(File.dirname(__FILE__),'views')
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
  
  get '/oauth2/callback' do
    token = Client.auth_code.get_token(params[:code], {:redirect_uri => REDIRECT_URI}, DEFAULT_OPTS)
    session[:token] = token.token
    Token[token.token] = token
    redirect "/"
  end

  get '/login' do 
    if session[:token].nil?
      redirect Client.auth_code.authorize_url({:redirect_uri =>  REDIRECT_URI, :scope => "user read write"})
    end
    redirect "/"
  end
  
  get "/user" do
    @user = oposRequest("/me")
    haml :user
  end
   
  def oposRequest(url)
    token  = Token[session[:token]]
    if !token.nil?
      resp = token.get(url)
      return JSON.parse(resp.body)
    end
    return {"Error" => "No token"}
  end

end
