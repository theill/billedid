ActionController::Routing::Routes.draw do |map|
  map.resources :photos, :member => {:download => :get}
  
  map.namespace :admin do |admin|
    admin.resources :photos
  end

  map.connect '/ping/close', :controller => 'photos', :action => 'closekeepalive'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "photos", :action => "new"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
