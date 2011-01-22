class ConnexionsController < ApplicationController
  def index
    @client = Connexion.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @client }
    end
  end

end
