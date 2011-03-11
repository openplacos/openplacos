class RegulationsController < ApplicationController
  # GET /sensors
  # GET /sensors.xml
  def index
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    @sensor = Regulation.new(@connexion,path)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sensors }
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
