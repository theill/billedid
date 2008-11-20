class Admin::PhotosController < ApplicationController
  before_filter :admin_required
  
  def index
    @photos = Photo.all(:conditions => {:parent_id => nil})

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photos }
    end
  end
end