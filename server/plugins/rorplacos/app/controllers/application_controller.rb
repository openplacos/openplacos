class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_locale, :set_style
  def set_locale
    if params[:locale]
      I18n.locale=params[:locale]
    else
      I18n.locale = extract_locale_from_accept_language_header
    end
  end
  private
  def extract_locale_from_accept_language_header
    req = request.env['HTTP_ACCEPT_LANGUAGE']
    if not req.nil? 
      return req.scan(/^[a-z]{2}/).first
    else
      return "en"
    end
  end
  
  def set_style
    @style = params[:style] || "beach.css"
  end


  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      ack = Opos_Connexion.instance.auth(user_name,password)
      if ack==true
        session[:user] = user_name
      end
      return ack
    end
  end


end
