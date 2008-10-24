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
  
  map.controller_actions 'about', %w[terms privacy about]
  
  map.root :controller => 'photos', :action => 'new'
end