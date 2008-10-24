class PhotosController < ApplicationController
  before_filter :lookup_photo, :only => [:show, :edit, :update]

  # GET /photos/1
  # GET /photos/1.xml
  def show
    respond_to do |format|
      format.html { @photo.generate unless @photo.exists? }
      format.jpg  { render_preview(@photo) }
      format.xml  { render :xml => @photo }
    end
  end

  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = Photo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo }
    end
  end

  # GET /photos/1/edit
  def edit
    
  end

  # POST /photos
  # POST /photos.xml
  def create
    @photo = Photo.new(params[:photo])

    respond_to do |format|
      if @photo.save
        format.html do 
          session[:photo_id] = @photo.id
          redirect_to edit_photo_path(@photo)
        end
        format.xml  { render :xml => @photo, :status => :created, :location => @photo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.xml
  def update
		
    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        # crop *and replace* existing image
        @photo.crop(params[:width].to_i, params[:height].to_i, params[:x1].to_i, params[:y1].to_i)
        format.html { redirect_to @photo }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def download
    photo = Photo.find(params[:id])
    send_file photo.full_filename(:final), :type => 'image/jpg', :disposition => 'attachment'
  end

	# helps fixing upload issues for Safari browser
  def closekeepalive
    response.headers['Connection'] = 'Close'
    render :text => ''
  end

  
  private
  def render_preview(photo)
    send_file photo.full_filename(:preview), :type => 'image/jpg', :disposition => 'inline'
  end
  
  def lookup_photo
		if session[:photo_id].blank?
			flash[:notice] = 'Dit BilledId blev ikke fundet. Systemet sletter automatisk gamle BilledID. Du kan lave et nyt BilledId med det samme.'
			redirect_to root_url
			return
		end
    @photo = Photo.find(session[:photo_id])
  end
  
end