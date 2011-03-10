class SensorsController < ApplicationController
  # GET /sensors
  # GET /sensors.xml
  def index
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    @sensor = Sensor.new(@connexion,path)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sensors }
    end
    
    @sensor.generate_graph
    
  end

  def set_regul
    path = params[:path]
    regul = Opos_Connexion.instance.reguls[path]
    option = {"threshold" => params[:th].to_f, "hysteresis" => params[:hy].to_f, "frequency" => params[:fe].to_f}
    regul.set(option)
    redirect_to :back
  end
  
end
