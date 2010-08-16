class PhotosController < ApplicationController
  before_filter :lookup_photo, :only => [:show, :edit, :update]
  
  # session :cookie_only => false, :only => :create
  # skip_before_filter :verify_authenticity_token, :only => :create
  
  # GET /photos/1
  def show
    respond_to do |format|
      format.html { @photo.generate unless @photo.exists? }
      format.jpg  { render_preview(@photo) }
    end
  end

  # GET /photos/new
  def new
    @photo = Photo.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /photos
  def create
    @photo = Photo.new(params[:photo])
    
    respond_to do |format|
      if @photo.save
        format.html do 
          session[:photo_id] = @photo.id
          redirect_to edit_photo_url(@photo)
        end
      else
        flash[:error] = "Du skal angive et foto i enten JPG eller PNG format"
        format.html { render :action => :new }
      end
    end
  end
  
  def edit
    
  end
  
  # PUT /photos/1
  def update
    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        # crop *and replace* existing image
        @photo.crop(params[:width].to_i, params[:height].to_i, params[:x1].to_i, params[:y1].to_i)
        
        # add id to session of our cropped image, to assist with creating menus
        session[:cropped_photo_id] = @photo.id
        
        format.html { redirect_to @photo }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def download
    # send_file photo.full_filename(:final), :type => 'image/jpg', :disposition => 'attachment'
    
    photo = Photo.find(params[:id])
    redirect_to photo.public_filename(:final)
  end
  
  module Foo
    include Prawn::Measurements

    module_function :in2pt, :ft2pt, :yd2pt, :mm2pt, :cm2pt, :dm2pt, :m2pt, :pt2mm
    module_function :ft2in, :yd2in, :cm2mm, :dm2mm, :m2mm
  end

  def pdf
    photo = Photo.find(params[:id])
    
    pdf = Prawn::Document.new(:page_size => 'A4') do
      # 136mm (width of image) and 102mm (height of image)
      image open(photo.public_filename(:final)), :width => Foo.mm2pt(136), :height => Foo.mm2pt(102), :position => :center, :vposition => :center
    end
    
    send_data pdf.render, :filename => "billedid.pdf", :type => "application/pdf"
  end
  
  # helps fixing upload issues for Safari browser
  def closekeepalive
    response.headers['Connection'] = 'Close'
    render :text => ''
  end
  
  private
  
  def render_preview(photo)
    redirect_to photo.public_filename(:preview)
    # send_file photo.full_filename(:preview), :type => 'image/jpg', :disposition => 'inline'
  end
  
  def lookup_photo
    @photo = Photo.find(session[:photo_id]) unless session[:photo_id].blank?
    unless @photo
      flash[:notice] = 'Dit foto blev ikke fundet. Systemet sletter automatisk gamle fotos. Du kan lave et nyt med det samme.'
      redirect_to(root_url)
    end
  end
  
end