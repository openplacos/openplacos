class UsersController < ApplicationController
  before_filter :authenticated, :except => :auth

  def index

    @user = User.find(session[:user_id])
   
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
