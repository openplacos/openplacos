class RoomsController < ApplicationController
  before_filter :authenticate
  # GET /rooms
  # GET /rooms.xml
  def index
    # service = DBus::SessionBus.instance.service("org.openplacos.server")
    # service.introspect
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    @rooms = Room.new(@connexion,path)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rooms }
    end
  end

end
