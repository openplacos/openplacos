require 'singleton'

DEFAULT_OPTS = {:mode=>:header, :header_format=>"OAuth %s", :param_name=>"oauth_token"}

class Connect
  include Singleton
  include Openplacos::Connection

  attr_reader :client, :redirect_uri

  def init
    @file_config = File.dirname(__FILE__) + "/connect.yaml"
    @url          = 'http://localhost:4567'
    @name         = 'web-client'
    @redirect_uri = 'http://localhost:9292/oauth2/callback'
    load_config
    
    if @token_params[@url].nil? #get token -- first time
      
      register()
      save_config
    end
    create_client()
  end
  
end


class WebClient < Sinatra::Base
   
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
    token = ::Connect.instance.client.auth_code.get_token(params[:code], {:redirect_uri => ::Connect.instance.redirect_uri}, DEFAULT_OPTS)
    session[:token] = token.token
    Token[token.token] = token
    redirect "/"
  end

  get '/login' do 
    if session[:token].nil?
      redirect ::Connect.instance.client.auth_code.authorize_url({:redirect_uri => ::Connect.instance.redirect_uri, :scope => "user read write"})
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
