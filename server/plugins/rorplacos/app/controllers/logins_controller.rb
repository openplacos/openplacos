class LoginsController < ApplicationController
  # "Create" a login, aka "log the user in"
  before_filter :authenticated, :except => [:login, :auth]
  
  def login
    respond_to do |format|
        format.html # login.html.erb
    end
  end
  
  def logout
    session["user"] = nil
    session["user_id"] = nil
    session[:locale] = nil
    session[:style]  = nil
    redirect_to root_url
  end
  
  def auth
    if User.authenticate(params[:login], params[:password])
      user = User.find(:first, :conditions => {:login => params[:login]})
      session[:user] = params[:login]
      session[:user_id] = user.id
      session[:style] = user.style
      session[:locale] = user.language
    end
    redirect_to root_url
  end
  
  
end
