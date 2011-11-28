class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def jasmine
    render :layout => false
  end
end
