class ApplicationController < ActionController::Base
  rescue_from ActionController::RoutingError, :with => :route_not_found
  rescue_from ActionController::MethodNotAllowed, :with => :invalid_method
  helper :all

  protect_from_forgery
  
  private
  
  def route_not_found
    render :file => "#{Rails.root}/public/404.html", :status => "404"
  end
  
  def invalid_method
    render :file => "#{Rails.root}/public/404.html", :status => "404"
  end  
  
end