class PixumController < ApplicationController
  before_filter :lookup_photo
  
  def new
    url = Pixum.new.transfer(@photo)
    unless url.blank?
      redirect_to url
    end
  end
  
  private
  
  def lookup_photo
    @photo = Photo.find(session[:photo_id]) unless session[:photo_id].blank?
		unless @photo
			flash[:notice] = 'Dit foto blev ikke fundet. Systemet sletter automatisk gamle fotos. Du kan lave et nyt med det samme.'
			redirect_to(root_url)
		end
  end
  
end