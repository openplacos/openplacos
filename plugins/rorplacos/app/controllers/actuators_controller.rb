class ActuatorsController < ApplicationController
  before_filter :authenticated
  # GET /actuators
  # GET /actuators.xml
  def index
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    
    if @connexion.readable?(path,session[:user]) # if actuator is readable
      @actuator = Actuator.new(@connexion,path)
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => {"state" => @actuator.state }}
        format.json { render :json => @actuator.state}
      end
    else
      respond_to do |format|
        format.html {render :partial => "shared/permission_denied"}
        format.xml  { render :xml =>  "Permission denied" }
      end
    end
  end
  
  def call
   path = '/'+ params[:path] ||= ""
   meth = params[:method]
   connexion = Opos_Connexion.instance
   if connexion.writeable?(path,session[:user])
     actuator = connexion.actuators[path]
     actuator.method(meth).call
   end 
   #~ respond_to do |format|
        #~ format.html { render :nothing}
        #~ format.xml  { render :nothing}
        #~ format.json { render :json => actuator.state}
   #~ end
   render :nothing => true
  end
  
  def graph
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    if @connexion.readable?(path,session[:user]) # if actuator is readable

      @actuator = Actuator.new(@connexion,path)
      maxtime = params[:time].to_i || 1
      @data = @actuator.generate_graph(maxtime)
      

      respond_to do |format|
        format.json  { render :json => @data}
        format.xml  { render :xml => @data}
      end
      
    else
      respond_to do |format|
        format.json  { render :json => "Permission denied"}
        format.xml  { render :xml => "Permission denied"}
      end
    end
  end

end