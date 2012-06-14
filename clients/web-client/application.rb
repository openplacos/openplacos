require 'singleton'

DEFAULT_OPTS = {:mode=>:header, :header_format=>"OAuth %s", :param_name=>"oauth_token"}

module Help
  def showroom
    roomlist = Hash.new
    oposRequest('/ressources').each do |mod|
      room = mod["name"].split("/")
      room.pop
      room.delete("")
      (roomlist[room.join('/')] || roomlist[room.join(' / ')] = [] )<< mod
    end 
    roomlist
  end 

end 


class Connect
  include Singleton
  include Openplacos::Connection

  attr_reader :client, :redirect_uri
  attr_accessor :token

  def init
    @file_config = File.dirname(__FILE__) + "/connect.yaml"
    @url          = 'http://localhost:4567'
    @name         = 'web-client'
    @redirect_uri = 'http://localhost:9292/oauth2/callback'
    @token = {}
    load_config
    
    if @token_params[@url].nil? #get token -- first time
      
      register()
      save_config
    end
    create_client()
  end
  
end


class WebClient < Sinatra::Base

  helpers Sinatra::ContentFor
  helpers Help
  
  # sinatra configuration
  set :static, true
  set :public_forder, File.join(File.dirname(__FILE__),'public')
  set :views,  File.join(File.dirname(__FILE__),'views')
  set :haml, :format => :html5
  
  enable :sessions
  enable :logging
  
 
  get '/' do
    haml :home
  end
  
  get '/oauth2/callback' do
    token = ::Connect.instance.client.auth_code.get_token(params[:code], {:redirect_uri => ::Connect.instance.redirect_uri}, DEFAULT_OPTS)
    session[:token] = token.token
    ::Connect.instance.token[token.token] = token
    redirect '/'
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
  
  get '/ressources/*' do
    path = "/"+params[:splat][0]
    @resp = oposRequest('/ressources'+path)
    if !@resp["Error"].nil?
      @error = "No ressource found under " + path
    end
      
    haml :view_resource
  end
   
  def oposRequest(url,parameters= {})
    token  = ::Connect.instance.token[session[:token]]
    if !token.nil?
      begin
        resp = token.get(url,:params => parameters)
      rescue
        return {"Error" => "404"}
      end
      return JSON.parse(resp.body)
    else
      redirect '/login'
    end 
    return {"Error" => "No token"}
  end

end
