require "openplacos/libclient"


module WebServerHelpers
  
  def set_header
    headers({"Access-Control-Allow-Headers" => "*", "Access-Control-Allow-Origin" => "*"})
  end
  
  ERROR_RESPONSE = JSON.unparse('Error' => "Invalid token")

  def is_an_object?
    Top.instance.exports.keys.include?("/"+params[:splat][0])
  end
  
  def objects
    Top.instance.exports
  end
  
  def object_introspect(path)
    {"name" => path, "interfaces" => Top.instance.exports[path].pin_web.introspect }
  end
  
  def introspect
    intro = Array.new
    objects.each_key do |path|
      intro << object_introspect(path)
    end
    intro
  end
  
  def read(path_,iface_)
    Dispatcher.instance.call(path_,iface_, :read,JSON.parse(params[:options] || "{}"))[0]
  end
  
  def read_history(path_,iface_,start_,end_)
    Resource.find_by_name(path_).interfaces.find_by_name(iface_).reads.collect do |r|
      [r.created_at.to_i*1000, r.value]
    end
  end
  
  def write(path_,iface_)
    Dispatcher.instance.call(path_,iface_, :write,JSON.parse(params[:value])[0],JSON.parse(params[:options] || "{}"))[0]
  end

  def verify_access(scope)
    token = OAuth2::Provider.access_token(nil, [scope.to_s], request)
    
    headers token.response_headers
    status  token.response_status
    
    return ERROR_RESPONSE unless token.valid?
    
    yield token
  end

  # helpers for website part
  def showroom
    roomlist = Hash.new
    introspect.each do |mod|
      room = mod["name"].split("/")
      room.pop
      room.delete("")
      (roomlist[room.join('/')] || roomlist[room.join(' / ')] = [] )<< mod
    end 
    roomlist
  end

  def base_url
    "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
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

  # disable this protection for rest api
  set :protection, :except => [:json_csrf, :remote_token, :frame_options]

  helpers ::WebServerHelpers

  # OAuth2 Permission configuration
  PERMISSIONS = {
    'read' => 'Read  access',
    'write' => 'Write access',
    'data' => 'DataBase access',
    'user' => 'User info'
  }
  
  # Create oauth2 provider
  OAuth2::Provider.realm = 'Opos oauth2 provider'
 
  # Password credential method
  OAuth2::Provider.handle_passwords do |client, login, password|
    user = User.find_by_login(login)
    if !user.nil? && user.authenticate?(password)
      user.grant_access!(client)
    else
      nil
    end
  end
 
  # For register client (User point of view)
  get '/oauth/apps/new' do
    @client = OAuth2::Model::Client.new
    haml :new_client
  end

  # Post method for register a client
  post '/oauth/apps.?:format?' do
    @client = OAuth2::Model::Client.new(params)
    if params[:format]=="json"
      content_type :json
      @client.save ? {"client_id" => @client.client_id, "client_secret" => @client.client_secret}.to_json : @client.errors.full_messages.to_json
    else
      @client.save ? haml(:show_client) : haml(:new_client)
    end
  end

  
  ## OAuth2 API
  # Denpending to the credential, the flow can be different.
  # The auth_code flow is 4 step :
  # * The client request authorisation (get) to the oauth endpoint (/oauth/authorize)
  # * The client is redirected to the login form
  # * The user grand the client
  # * The autorization code is given to the client
  #
  # The client exchange the auth_code for a token (post on /oauth/authorize)
  
  # Access token and authoririsation end point
  [:get, :post].each do |method|
    __send__ method, '/oauth/authorize' do
      
      # find the user by its login (nil if not logged)
      @owner  = User.find_by_id(session[:user_id])
      
      # parse the OAuth request (like grant_type etc)
      # return a Authorisation object
      @oauth2 = OAuth2::Provider.parse(@owner, request)
      
      # Client already autorized ?
      # Redirect to client if already granted.
      # User must be logged 
      redirect @oauth2.redirect_uri, @oauth2.response_status  if @oauth2.redirect? 

      # Set the header and the status of the response
      headers @oauth2.response_headers
      status  @oauth2.response_status

      # render the login view if there is no error
      # login view will post on /oauth/login
      @oauth2.response_body || haml(:login)
    end
  end
  
  # Recieve the login post form
  post '/oauth/login' do
    
    # Find the user by it's login
    @user = User.find_by_login(params[:login])
    
    # Parse the request
    @oauth2 = OAuth2::Provider.parse(@user, request)
    
    #verify if the password is ok, else render the login form
    if @user and @user.authenticate?(params[:password])
    
      # Store the userid in the session
      session[:user_id] = @user.id
      
      #redirect to the client if already granted
      redirect @oauth2.redirect_uri, @oauth2.response_status if @oauth2.redirect? 
        
      # render the grant view
      # grant view will post on /oauth/allow
      haml :authorize
    else
      #render login view
      haml :login
    end
  end
  
  # Grant end point
  post '/oauth/allow' do
  
    # User should be logged now
    @user = User.find_by_id(session[:user_id])
    
    #create the authorization
    @auth = OAuth2::Provider::Authorization.new(@user, params)

    #grand or deny acces, according to the post params
    if params['allow'] == '1'
      @auth.grant_access!
    else
      @auth.deny_access!
    end
    
    # redirect to the client
    redirect @auth.redirect_uri, @auth.response_status
  end


  ## User api
  
  
  # user creation view
  get '/users/new' do
    @user = User.new
    haml :new_user
  end

  # Post method for user creation
  post '/users/create' do
    @user = User.create(params)
    if @user.save
      haml :create_user
    else
      haml :new_user
    end
  end
  
  
  # Opos api
  get '/ressources' do
    set_header
    content_type :json
    introspect.to_json
  end
  
  get '/ressources/*' do
    set_header
    content_type :json
    path = "/"+params[:splat][0]
    if is_an_object?
      if params[:iface]
        if params[:start_time]
          read_history(path,params[:iface],params[:start_time],params[:end_time]).to_json
        else
          {"value" => read(path,params[:iface])}.to_json
        end
      else
        object_introspect(path).to_json
      end
    else
      status 404
      {"Error" => "#{path} is not an object"}
    end
  end
  
  post '/ressources/*' do
    set_header
    content_type :json
    path = "/"+params[:splat][0]
    if is_an_object?
      if params[:iface]
        {"status" => write(path,params[:iface])}.to_json
      else
        status 404
        {"Error" => "An iface is required"}
      end
    else
      status 404
      {"Error" => "#{path} is not an object"}
    end
  end
  
  # user api
  
  get '/me' do
    set_header
    content_type :json
    verify_access "user" do |token|
      JSON.unparse('username' => token.owner.login)
    end
  end
  
  options '*' do
    response['Access-Control-Allow-Origin' ] = '*'
    response["Access-Control-Allow-Headers"] = 'origin, authorization, content-type, accept'
    response['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  end


  ############################################
  ####           User application         ####
  ############################################
  get '/' do
    haml :home
  end
  
  get '/overview' do
    haml :overview,  :locals => {:objects => introspect}
  end
    
  

end

class ThinServer < Thin::Server

  def initialize(bind,port, pid_dir_)
    if (pid_dir_ == "")
      pid_dir = File.dirname(__FILE__) 
    else
      pid_dir = pid_dir_
    end
    @pid_file = "#{pid_dir}/openplacos.pid"
    @log_file = "#{File.dirname(__FILE__)}/opos-daemon.log"

    super(bind,port, :signals => false) do
      use Rack::CommonLogger
      use Rack::ShowExceptions
      map "/" do
        run ::WebServer 
      end
    end  
  end

end
