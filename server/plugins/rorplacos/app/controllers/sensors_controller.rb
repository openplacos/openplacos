class SensorsController < ApplicationController
  # GET /sensors
  # GET /sensors.xml
  
  def index
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    @sensor = Sensor.new(@connexion,path)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @sensor.value}
      format.xml  { render :xml => {"value" => @sensor.value}}
    end
  end
  
  def graph
    path = '/'+ params[:path] ||= ""
    @connexion = Opos_Connexion.instance
    @sensor = Sensor.new(@connexion,path)
    if not params[:start_date].nil?
      start_date = Time.at(params[:start_date].to_i)
    else
      start_date = 1.hours.ago 
    end
    if not params[:end_date].nil?
      end_date = Time.at(params[:end_date].to_i)
    else
      end_date = Time.now
    end
    @data = @sensor.generate_graph(start_date,end_date)
    
    respond_to do |format|
      format.json  { render :json => @data}
      format.xml  { render :xml => @data}
    end

  end
  

end
