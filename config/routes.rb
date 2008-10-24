ActionController::Routing::Routes.draw do |map|
  
  def map.controller_actions(controller, aktions)
    aktions.each do |action|
      self.send("#{controller}_#{action}", "#{action}", :controller => controller, :action => action)
    end
  end

  map.resources :photos, :member => {:download => :get}
  
  map.namespace :admin do |admin|
    admin.resources :photos
  end

  map.connect '/ping/close', :controller => 'photos', :action => 'closekeepalive'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "photos", :action => "new"
  map.controller_actions 'about', %w[terms privacy about]
end
