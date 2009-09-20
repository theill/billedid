class ApplicationController < ActionController::Base
	include HoptoadNotifier::Catcher
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def admin_required
    authenticate_or_request_with_http_basic do |username, password|
      username == "admin" and password == "guitar42secret"
    end
  end
  
end