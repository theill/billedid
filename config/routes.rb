ActionController::Routing::Routes.draw do |map|
  map.resources :photos, :only => [:new, :create, :edit, :update, :show], :member => {:download => :get, :pdf => :get}
  map.resources :pixum, :only => [:new]
  
  map.root :controller => 'photos', :action => 'new'
	
	map.privacy 'fortrolighed', :controller => 'about', :action => 'privacy'
	map.guide 'vejledning', :controller => 'about', :action => 'guide'
	
  # safari hack
  map.connect '/ping/close', :controller => 'photos', :action => 'closekeepalive'
end