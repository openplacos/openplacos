class RoomsController < ApplicationController
  before_filter :authenticated
  # GET /rooms
  # GET /rooms.xml
  def index
    # service = DBus::SessionBus.instance.service("org.openplacos.server")
    # service.introspect
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    
    if @connexion.readable?(path,session[:user]) # if sensor is readable
      @rooms = Room.new(@connexion,path)
    
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @rooms }
      end
    else
      respond_to do |format|
        format.html {render :partial => "shared/permission_denied"}
        format.xml  { render :xml => {"value" => "Permission denied"}}
      end
    end
    
  end

end
