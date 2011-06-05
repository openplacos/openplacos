require 'digest/md5'

class UsersController < ApplicationController
  before_filter :authenticated, :except => :auth

  def index

    @user = User.find(session[:user_id])

    # get the email from URL-parameters or what have you and make lowercase
    email_address = @user.email || "default"

    # create the md5 hash
    hash = Digest::MD5.hexdigest(email_address.downcase)

    # compile URL which can be used in <img src="RIGHT_HERE"...
    @avatar = "http://www.gravatar.com/avatar/#{hash}?d=mm"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    @user = User.find(session[:user_id])
  end
  
  def update
    @user = User.find(session[:user_id])
 
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to("/users",
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
