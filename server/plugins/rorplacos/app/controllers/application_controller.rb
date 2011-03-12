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
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end
  
  def set_style
  @style = params[:style] || "style.css"
  end

end
