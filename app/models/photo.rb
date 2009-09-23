class Photo < ActiveRecord::Base
	has_attachment :content_type => :image, 
		:storage => :s3,
    # :path_prefix => "tmp/#{table_name}",
    :processor => :rmagick,
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

  # def resize_image(img, size)
  #   # Get rid of all colour profiles.  They take up a lot of space.
  #   img.strip
  #   img.quality self.quality
  #   super
  # end

  def exists?
    File.exists?("#{RAILS_ROOT}/tmp/#{self.full_filename(:final)}") && !Rails.env.development?
  end
  
  def generate
    # see https://asp.photoprintit.de/microsite/10021/quality.php
    # 1600x1200
    
    if self.attachment_options[:storage] == :s3
      cropped = self.public_filename(:cropped)
      final = self.public_filename(:final)
      preview = self.public_filename(:preview)
    elsif self.attachment_options[:storage] == :file_system
      cropped = self.full_filename(:cropped)
      final = self.full_filename(:final)
      preview = self.full_filename(:preview)
    end
    
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
    if exists?
      File.delete("#{RAILS_ROOT}/tmp/#{self.full_filename(:cropped)}")
      File.delete("#{RAILS_ROOT}/tmp/#{self.full_filename(:final)}")
    end
    
    bg = ["#{RAILS_ROOT}/public/images/billedid-info.png",
      "#{RAILS_ROOT}/public/images/1674_azoresleaf_1600x1200.jpg",
      "#{RAILS_ROOT}/public/images/1678_walenstadtberg_1600x1200.jpg",
      "#{RAILS_ROOT}/public/images/1690_playkiss_1600x1200.jpg",
      "#{RAILS_ROOT}/public/images/1696_afterrain_1600x1200.jpg",
      "#{RAILS_ROOT}/public/images/1698_betweenthemountains_1600x1200.jpg"].first
    
    # image.run_command "convert -strip -quality #{self.quality} -size #{tiled_width}x#{tiled_height} tile:#{fn} #{tiled}"    
    # image.run_command "composite -strip -quality #{self.quality} -geometry #{tiled_width}x#{tiled_height}+#{border}+#{border} #{tiled} #{bg} #{final}"
    
    # image.strip!
    # image.change_geometry!("#{tiled_width}x#{tiled_height}") do |cols, rows, img|
    #   img.resize!(cols, rows)
    # end
    # image.write(tiled) do
    #   self.quality = quality
    # end
    
    # create new memory image with tiled image (2x2 row)
    tiled_image = Magick::Image.new(tiled_width, tiled_height) do
      self.background_color = 'red'
    end
    # tiled_image.composite_tiled!(Magick::Image.read(cropped)[0]) (rmagick 2.x)
    tiled_image.composite!(Magick::Image.read(cropped)[0], 0, 0, Magick::OverCompositeOp)
    tiled_image.composite!(Magick::Image.read(cropped)[0], width, 0, Magick::OverCompositeOp)
    tiled_image.composite!(Magick::Image.read(cropped)[0], 0, height, Magick::OverCompositeOp)
    tiled_image.composite!(Magick::Image.read(cropped)[0], width, height, Magick::OverCompositeOp)
    
    # apply tiled image over background
    image = Magick::Image.read(bg)[0]
    image.composite!(tiled_image, border, border, Magick::OverCompositeOp)
    
    if self.attachment_options[:storage] == :s3
      fn = "#{RAILS_ROOT}/tmp/#{self.full_filename(:final)}"
      image.write(fn)
      AWS::S3::S3Object.store(self.full_filename(:final), open(fn), 'billedid', :access => :public_read, :content_type => 'image/jpg', :content_disposition => 'attachment')
    elsif self.attachment_options[:storage] == :file_system
      image.write(final)
    end
    
    # do preview of it
    image.change_geometry!("400x300>") do |cols, rows, img|
      img.resize!(cols, rows)
    end
    
    if self.attachment_options[:storage] == :s3
      fn = "#{RAILS_ROOT}/tmp/#{self.full_filename(:preview)}"
      image.write(fn)
      AWS::S3::S3Object.store(self.full_filename(:preview), open(fn), 'billedid', :access => :public_read)
    elsif self.attachment_options[:storage] == :file_system
      image.write(preview)
    end
    
    # image.run_command "montage #{fn} #{fn} #{fn} #{fn} -background #eeeeee -tile 2x2 -geometry 35x45+1+1 -size 1536x1024 montage.jpg"
    # image.run_command "montage #{fn} #{fn} #{fn} #{fn} #{fn} #{fn} -background #ffffff -tile 3x2 -geometry +1+1 -repage 1600x1200 montage_preview.jpg"
  end
  
  # see http://www.imagemagick.org/Usage/montage/#polaroid for nice effect
  # montage -size 400x400 null: '../photo_store/*_orig.jpg' null: -thumbnail 200x200 -bordercolor Lavender -background black +polaroid  -resize 30%  -background LightGray -geometry -10+2  -tile x1    polaroid_overlap.jpg
  
  def crop(width, height, x1, y1)
    if self.attachment_options[:storage] == :s3
      image = Magick::Image.read(self.public_filename)[0]
    elsif self.attachment_options[:storage] == :file_system
      image = Magick::Image.read(self.full_filename)[0]
    end
		thumbnail = self.thumbnails.first # NASTY: must fix
		ratio = self.width / thumbnail.width.to_f
		
		destination_width		= (width * ratio).to_i
		destination_height	= (height * ratio).to_i
		destination_x1			= (x1 * ratio).to_i
		destination_y1			= (y1 * ratio).to_i
		
    # image.crop "#{destination_width}x#{destination_height}+#{destination_x1}+#{destination_y1}"
    # image.write(self.full_filename(:cropped))
    # image.run_command "mogrify -strip -quality #{self.quality} -type Grayscale #{self.full_filename(:cropped)}" if self.grayscale
    # image.run_command "convert -strip -quality #{self.quality} -resize 413x531! #{self.full_filename(:cropped)} #{self.full_filename(:cropped)}" 
    image.crop!(destination_x1, destination_y1, destination_width, destination_height)
    image.strip!
    image = image.quantize(256, Magick::GRAYColorspace) if self.grayscale
    image.change_geometry!("413x531!") do |cols, rows, img|
      img.resize!(cols, rows)
    end
    
    if self.attachment_options[:storage] == :s3
      path = RAILS_ROOT + '/tmp/' + self.full_filename(:cropped)
      path = path.gsub('/' + path.split('/').last, '')
      FileUtils.mkdir_p path
      
      image.write(RAILS_ROOT + '/tmp/' + self.full_filename(:cropped)) do
        self.quality = quality
      end
      
      AWS::S3::S3Object.store(self.full_filename(:cropped), open(RAILS_ROOT + '/tmp/' + self.full_filename(:cropped)), 'billedid', :access => :public_read)
      
      # remove final image in case it has already been generated
      File.delete(RAILS_ROOT + '/tmp/' + self.full_filename(:final)) if exists?
      
    elsif self.attachment_options[:storage] == :file_system
      image.write(self.full_filename(:cropped)) do
        self.quality = quality
      end
      
      # save to force thumbnails to be updated
      # self.save

      # remove final image in case it has already been generated
      File.delete(self.full_filename(:final)) if exists?
    end
  end
end