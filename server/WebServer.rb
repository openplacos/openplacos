ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "test.db", :pool => 25)
ActiveRecord::Base.logger = Logger.new('test.log')

module WebServerHelpers
  
  ERROR_RESPONSE = JSON.unparse('Error' => "Invalid token")

  def is_an_object?
    Top.instance.config_export.include?("/"+params[:splat][0])
  end

  def verify_access(scope)
    token = OAuth2::Provider.access_token(nil, [scope.to_s], request)
    
    headers token.response_headers
    status  token.response_status
    
    return ERROR_RESPONSE unless token.valid?
    
    yield token
  end

end

class WebServer < Sinatra::Base
  
  # sinatra configuration
  set :static, true
  set :public_forder, settings.root + '/public'
  set :views,  settings.root + '/views'
  set :haml, :format => :html5
  
  enable :sessions
  enable :logging

  helpers ::WebServerHelpers

  # oauth2 configuration
  PERMISSIONS = {
    'read' => 'Read  access',
    'write' => 'Write access',
    'data' => 'DataBase access',
    'user' => 'User info'
  }
  
  OAuth2::Provider.realm = 'Opos oauth2 provider'
 
  # for register client
  get '/oauth/apps/new' do
    @client = OAuth2::Model::Client.new
    haml :new_client
  end

  post '/oauth/apps.?:format?' do
    @client = OAuth2::Model::Client.new(params)
    if params[:format]=="json"
      content_type :json
      @client.save ? {"client_id" => @client.client_id, "client_secret" => @client.client_secret}.to_json : @client.errors.full_messages.to_json
    else
      @client.save ? haml(:show_client) : haml(:new_client)
    end
  end

  
  # oauth2 api
  [:get, :post].each do |method|
    __send__ method, '/oauth/authorize' do
      @owner  = User.find_by_id(session[:user_id])
      @oauth2 = OAuth2::Provider.parse(@owner, request)
      
      
      if @oauth2.redirect?
        redirect @oauth2.redirect_uri, @oauth2.response_status
      end

      headers @oauth2.response_headers
      status  @oauth2.response_status

      @oauth2.response_body || haml(:login)
    end
  end
  
  post '/oauth/allow' do
    @user = User.find_by_id(session[:user_id])
    @auth = OAuth2::Provider::Authorization.new(@user, params)

    if params['allow'] == '1'
      puts "acces granted"
      @auth.grant_access!
    else
      puts "acces denied"
      @auth.deny_access!
    end
    redirect @auth.redirect_uri, @auth.response_status
  end

  post '/oauth/login' do
    puts "params: #{params.inspect}"
    @user = User.find_by_login(params[:login])
    if @user.authenticate?(params[:password])
      @oauth2 = OAuth2::Provider.parse(@user, request)
      session[:user_id] = @user.id
      haml(@user ? :authorize : :login)
    else
      redirect '/oauth/authorize'
    end
  end
  
  # user creation
  get '/users/new' do
    @user = User.new
    haml :new_user
  end

  post '/users/create' do
    @user = User.create(params)
    if @user.save
      haml :create_user
    else
      haml :new_user
    end
  end
  
  
  # Opos api
  
  get '/' do
    haml :home
  end
  
  get '/ressources' do
    content_type :json
    {"objects" => Top.instance.config_export}.to_json
  end
  
  get '/ressources/*' do
    content_type :json
    path = "/"+params[:splat][0]

    if is_an_object?
      {"name" => path, "interfaces" => Top.instance.exports[path].pin_web.ifaces}.to_json
    else
      {"Error" => "#{path} is not an object"}
    end
  end
  
  # user api
  
  get '/me' do
    content_type :json
    verify_access "user" do |token|
      JSON.unparse('username' => token.owner.login)
    end
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
