class Photo < ActiveRecord::Base
	has_attachment :content_type => :image, 
		:storage => :file_system,
		:processor => 'MiniMagick',
		:max_size => 10.megabytes,
		:thumbnails => {
		  :thumbnail => '480>'
		}
    # :resize_to => '1024>',
    # :thumbnails => { 
    #   :tiny => '35x45',
    #   :small => '70x90',
    #   :medium => '140x180',
    #   :large => '280x360',
    #       :cropped => '10x10',
    #       :preview => '400x300',
    #       :canvas => '1600x1200'
    # }
		
  validates_as_attachment

#   def resize_image(img, size)
#     # Get rid of all colour profiles.  They take up a lot of space.
#     img.strip
#     img.quality 60
#     super
#   end
# 

  def exists?
    File.exists?(self.full_filename(:final))
  end
  
  def generate
    # see https://asp.photoprintit.de/microsite/10021/quality.php
    # 1600x1200
    
    fn = self.full_filename(:cropped)
    final = self.full_filename(:final)
    
    # requirements: each profile picture must be 35mm in width and 45mm in height
    # converted to pixels with 300dpi (on a 13x10cm => 13.6x10.2cm => 1536x1024 layer) this is 
    # 1536 / 13.6 = 112.941176 pixels/cm
    # 1024 / 10.2 = 100.392157 pixels/cm
    # 3.5 cm * 112.941176 pixels = 395.294116 => 395
    # 4.5 cm * 100.392157 pixels = 451.764706 => 452
    # - alternate
    # 1mm = 0.0393700787inches => 35mm = 1.37795275inches
    # 1.37795275inches * 300dpi => 413.385826 pixels
    # 45mm = 1.77165354inches
    # 1.77165354inches * 300dpi => 531.496062
    
    width, height = 413, 531
    
    page_weight, page_height = 1606, 1205 # based on 13.6x10.2
    
    # TODO: convert to tiff og png to avoid losing quality when calling composite multiple times
    
    image = MiniMagick::Image.from_file(fn)
    image.run_command "convert -size #{page_weight}x#{page_height} xc:grey -font Arial -pointsize 72 -fill xc:black -draw \"text 900,100 'billedID.dk'\" -draw \"text 900,200 'gratis pasfoto'\" #{final}"
    image.run_command "composite -geometry #{height}x#{width}+24+24 #{fn} #{final} #{final}"
    image.run_command "composite -geometry #{height}x#{width}+#{width}+24 #{fn} #{final} #{final}"
    image.run_command "composite -geometry #{height}x#{width}+24+#{height} #{fn} #{final} #{final}"
    image.run_command "composite -geometry #{height}x#{width}+#{width}+#{height} #{fn} #{final} #{final}"
    
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
    image = MiniMagick::Image.from_file(self.full_filename(:thumbnail))
    image.crop "#{width}x#{height}+#{x1}+#{y1}"
    image.write(self.full_filename(:cropped))
    image.run_command "mogrify -type Grayscale #{self.full_filename(:cropped)}" if self.grayscale
  end
  
end