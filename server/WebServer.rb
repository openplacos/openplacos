ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "test.db", :pool => 25)
ActiveRecord::Base.logger = Logger.new('test.log')

module WebServerHelpers

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
    'superman' => 'Time Travel'
  }
  
  OAuth2::Provider.realm = 'Opos oauth2 provider'

  
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

  post '/login' do
    @user = User.find_by_login(params[:login])
    if @user.authenticate?(params[:password])
      @oauth2 = OAuth2::Provider.parse(@user, request)
      session[:user_id] = @user.id
      haml(@user ? :authorize : :login)
    else
      redirect '/oauth/authorize'
    end
  end
  
  # Opos api
  
  get '/' do
    haml :home
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
