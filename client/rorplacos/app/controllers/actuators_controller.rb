class ActuatorsController < ApplicationController
  # GET /actuators
  # GET /actuators.xml
  def index
    @actuators = Actuator.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @actuators }
    end
  end

  # GET /actuators/1
  # GET /actuators/1.xml
  def show
    @actuator = Actuator.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @actuator }
    end
  end

  # GET /actuators/new
  # GET /actuators/new.xml
  def new
    @actuator = Actuator.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @actuator }
    end
  end

  # GET /actuators/1/edit
  def edit
    @actuator = Actuator.find(params[:id])
  end

  # POST /actuators
  # POST /actuators.xml
  def create
    @actuator = Actuator.new(params[:actuator])

    respond_to do |format|
      if @actuator.save
        format.html { redirect_to(@actuator, :notice => 'Actuator was successfully created.') }
        format.xml  { render :xml => @actuator, :status => :created, :location => @actuator }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @actuator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /actuators/1
  # PUT /actuators/1.xml
  def update
    @actuator = Actuator.find(params[:id])

    respond_to do |format|
      if @actuator.update_attributes(params[:actuator])
        format.html { redirect_to(@actuator, :notice => 'Actuator was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @actuator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /actuators/1
  # DELETE /actuators/1.xml
  def destroy
    @actuator = Actuator.find(params[:id])
    @actuator.destroy

    respond_to do |format|
      format.html { redirect_to(actuators_url) }
      format.xml  { head :ok }
    end
  end
end
