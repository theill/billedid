class Photo < ActiveRecord::Base
	
	has_attachment :content_type => :image, 
		:storage => :file_system,
		:processor => 'MiniMagick',
		:max_size => 5.megabytes,
		:resize_to => '2000x1500>',
		:thumbnails => {
		  :thumbnail => '480>'
		}
  
  named_scope :obsoleted, lambda { { :conditions => ['created_at < ? AND parent_id IS NULL', -2.hours.from_now] } }
		
  validates_as_attachment

	def quality
		75
	end

  # Map file extensions to mime types.
  # Thanks to bug in Flash 8 the content type is always set to application/octet-stream.
  # From: http://blog.airbladesoftware.com/2007/8/8/uploading-files-with-swfupload
  def swf_uploaded_data=(data)
    data.content_type = MIME::Types.type_for(data.original_filename)
    self.uploaded_data = data
  end

  def resize_image(img, size)
    # Get rid of all colour profiles.  They take up a lot of space.
    img.strip
    img.quality self.quality
    super
  end

  def exists?
    File.exists?(self.full_filename(:final)) && !Rails.env.development?
  end
  
  def generate
    # see https://asp.photoprintit.de/microsite/10021/quality.php
    # 1600x1200
    
    fn = self.full_filename(:cropped)
		tiled = self.full_filename(:tiled)
    final = self.full_filename(:final)
    
    # requirements: each profile picture must be 35mm in width and 45mm in height
    # converted to pixels with 300dpi (on a 13x10cm => 13.6x10.2cm => 1536x1024 layer) this is 
    # 1536 / 13.6 = 112.941176 pixels/cm
    # 1024 / 10.2 = 100.392157 pixels/cm
    # 4.5 cm * 112.941176 pixels = 508.235292 => 508
    # 3.5 cm * 100.392157 pixels = 351.372549 => 351
    # - alternate
    # 1mm = 0.0393700787inches => 35mm = 1.37795275inches
    # 1.37795275inches * 300dpi => 413.385826 pixels
    # 45mm = 1.77165354inches
    # 1.77165354inches * 300dpi => 531.496062
    
    # width, height = 508, 351

    # 1600 / 13 = 123.076923 pixels/cm => * 3.5 = 430.76923 pixels
    # 1200 / 10 = 120 pixels/cm => * 4.5 = 540 pixels
    # width, height = 431, 540
    width, height = 413, 531
		tiled_width, tiled_height = width * 2, height * 2
    
    page_width, page_height = 1600, 1200 # based on 13.6x10.2
    
    # TODO: convert to tiff og png to avoid losing quality when calling composite multiple times
    
    border = 64
    
    # remove final image in case it has already been generated
    File.delete fn if exists?
    File.delete final if exists?
    
    bg = ["#{RAILS_ROOT}/public/images/billedid-info.png",
      "#{RAILS_ROOT}/public/images/1674_azoresleaf_1600x1200.jpg",
      "#{RAILS_ROOT}/public/images/1678_walenstadtberg_1600x1200.jpg",
      "#{RAILS_ROOT}/public/images/1690_playkiss_1600x1200.jpg",
      "#{RAILS_ROOT}/public/images/1696_afterrain_1600x1200.jpg",
      "#{RAILS_ROOT}/public/images/1698_betweenthemountains_1600x1200.jpg"].first
    
    image = MiniMagick::Image.from_file(fn)
		image.run_command "convert -strip -quality #{self.quality} -size #{tiled_width}x#{tiled_height} tile:#{fn} #{tiled}"		
		image.run_command "composite -strip -quality #{self.quality} -geometry #{tiled_width}x#{tiled_height}+#{border}+#{border} #{tiled} #{bg} #{final}"
    
    # do preview of it
    image = MiniMagick::Image.from_file(final)
    image.resize "400x300>"
    image.write(self.full_filename(:preview))
    
    # image.run_command "montage #{fn} #{fn} #{fn} #{fn} -background #eeeeee -tile 2x2 -geometry 35x45+1+1 -size 1536x1024 montage.jpg"
    # image.run_command "montage #{fn} #{fn} #{fn} #{fn} #{fn} #{fn} -background #ffffff -tile 3x2 -geometry +1+1 -repage 1600x1200 montage_preview.jpg"
  end
  
  # see http://www.imagemagick.org/Usage/montage/#polaroid for nice effect
  # montage -size 400x400 null: '../photo_store/*_orig.jpg' null: -thumbnail 200x200 -bordercolor Lavender -background black +polaroid  -resize 30%  -background LightGray -geometry -10+2  -tile x1    polaroid_overlap.jpg
  
  def crop(width, height, x1, y1)
    image = MiniMagick::Image.from_file(self.full_filename)
		thumbnail = self.thumbnails.first # NASTY: must fix
		ratio = self.width / thumbnail.width.to_f
		
		destination_width		= (width * ratio).to_i
		destination_height	= (height * ratio).to_i
		destination_x1			= (x1 * ratio).to_i
		destination_y1			= (y1 * ratio).to_i
		
    image.crop "#{destination_width}x#{destination_height}+#{destination_x1}+#{destination_y1}"
    image.write(self.full_filename(:cropped))
    image.run_command "mogrify -strip -quality #{self.quality} -type Grayscale #{self.full_filename(:cropped)}" if self.grayscale
		image.run_command "convert -strip -quality #{self.quality} -resize 413x531! #{self.full_filename(:cropped)} #{self.full_filename(:cropped)}" 
    
    # save to force thumbnails to be updated
    # self.save
    
    # remove final image in case it has already been generated
    File.delete(self.full_filename(:final)) if exists?
  end
  
end