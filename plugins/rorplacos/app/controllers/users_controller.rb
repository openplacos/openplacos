require 'digest/md5'

class UsersController < ApplicationController
  before_filter :authenticated

  def index

    @users = User.order("login DESC").all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end
  
  def profil
    redirect_to "/users/#{session[:user_id]}"
  end
  
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    @user = User.find(session[:user_id])
  end
  
  def update
    @user = User.find(session[:user_id])
    session[:style] = @user.style
    session[:locale] = @user.language
 
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to("/profil",
                      :notice => 'profile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors,
                      :status => :unprocessable_entity }
      end
    end
  end
  
end
