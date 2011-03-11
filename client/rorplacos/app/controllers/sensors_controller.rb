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

end
