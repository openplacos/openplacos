class SensorsController < ApplicationController
  # GET /sensors
  # GET /sensors.xml
  def index
    @sensors = Sensor.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sensors }
    end
  end

  # GET /sensors/1
  # GET /sensors/1.xml
  def show
    @sensor = Sensor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sensor }
    end
  end

  # GET /sensors/new
  # GET /sensors/new.xml
  def new
    @sensor = Sensor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sensor }
    end
  end

  # GET /sensors/1/edit
  def edit
    @sensor = Sensor.find(params[:id])
  end

  # POST /sensors
  # POST /sensors.xml
  def create
    @sensor = Sensor.new(params[:sensor])

    respond_to do |format|
      if @sensor.save
        format.html { redirect_to(@sensor, :notice => 'Sensor was successfully created.') }
        format.xml  { render :xml => @sensor, :status => :created, :location => @sensor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sensor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sensors/1
  # PUT /sensors/1.xml
  def update
    @sensor = Sensor.find(params[:id])

    respond_to do |format|
      if @sensor.update_attributes(params[:sensor])
        format.html { redirect_to(@sensor, :notice => 'Sensor was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sensor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sensors/1
  # DELETE /sensors/1.xml
  def destroy
    @sensor = Sensor.find(params[:id])
    @sensor.destroy

    respond_to do |format|
      format.html { redirect_to(sensors_url) }
      format.xml  { head :ok }
    end
  end
end
