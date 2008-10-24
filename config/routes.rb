ActionController::Routing::Routes.draw do |map|
  map.resources :photos, :member => {:download => :get}
  
  map.namespace :admin do |admin|
    admin.resources :photos
  end

  map.root :controller => 'photos', :action => 'new'
end