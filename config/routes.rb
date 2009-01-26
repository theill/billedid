ActionController::Routing::Routes.draw do |map|
  map.resources :photos, :only => [:new, :create, :edit, :update, :show], :member => {:download => :get}
  
  map.namespace :admin do |admin|
    admin.resources :photos
  end

  map.root :controller => "photos", :action => "new"
	
	map.privacy 'fortrolighed', :controller => 'about', :action => 'privacy'
	
  # safari hack
  map.connect '/ping/close', :controller => 'photos', :action => 'closekeepalive'
end