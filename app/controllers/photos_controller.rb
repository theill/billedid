class PhotosController < ApplicationController

  # GET /photos/1
  # GET /photos/1.xml
  def show
    @photo = Photo.find(params[:id])

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
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.xml
  def create
    @photo = Photo.new(params[:photo])

    respond_to do |format|
      if @photo.save
        format.html { redirect_to edit_photo_path(@photo) }
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
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        # crop *and replace* existing image
        @photo.crop(params[:width], params[:height], params[:x1], params[:y1])

        format.html { redirect_to @photo }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to(photos_url) }
      format.xml  { head :ok }
    end
  end
  
  def download
    photo = Photo.find(params[:id])
    
    send_file photo.full_filename(:final), :type => 'image/jpg', :disposition => 'attachment'
  end

  def closekeepalive
    response.headers['Connection'] = 'Close'
    render :text => ''
  end

  
  private
  
  def render_preview(photo)
    send_file photo.full_filename(:preview), :type => 'image/jpg', :disposition => 'inline'
  end
  
end