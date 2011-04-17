class ActuatorsController < ApplicationController
  # GET /actuators
  # GET /actuators.xml
  def index
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    @actuator = Actuator.new(@connexion,path)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @actuators }
    end
  end
  
  def call
   path = params[:path]
   meth = params[:meth]
   actuator = regul = Opos_Connexion.instance.actuators[path]
   actuator.method(meth).call
   redirect_to :back
  end

end
