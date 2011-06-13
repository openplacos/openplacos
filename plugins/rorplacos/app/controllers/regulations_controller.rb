class RegulationsController < ApplicationController
  before_filter :authenticated
  # GET /sensors
  # GET /sensors.xml
  def index
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    
    if @connexion.writeable?(path,session[:user]) # if actuator is readable

      @regul = Regulation.new(@connexion,path)
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @regul }
      end
    else
      respond_to do |format|
        format.html {render :partial => "shared/permission_denied"}
        format.xml  { render :xml => "permission denied" }
      end
    end
  end

  def set
    path = params[:path]
    regul = Opos_Connexion.instance.reguls[path]
    option = {"threshold" => params[:th].to_f, "hysteresis" => params[:hy].to_f, "frequency" => params[:fe].to_f}
    if params[:act]  
      regul.set(option)
    else
      regul.unset
    end
    redirect_to :back
  end
  
end
