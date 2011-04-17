class SensorsController < ApplicationController
  # GET /sensors
  # GET /sensors.xml
  
  def index
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    @sensor = Sensor.new(@connexion,path)
    @data = @sensor.generate_graph(1)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @sensor.value}
      format.xml  { render :xml => @sensor.value}
    end
  end
  
  def graph
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    @sensor = Sensor.new(@connexion,path)
    time = params[:time].to_i || 1
    @data = @sensor.generate_graph(time)
    
    respond_to do |format|
      format.json  { render :json => @data}
      format.xml  { render :xml => @data}
    end
  end
  

end
