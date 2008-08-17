class Photo < ActiveRecord::Base
	has_attachment :content_type => :image, 
		:storage => :file_system,
		:processor => 'MiniMagick',
		:max_size => 10.megabytes,
		:resize_to => '1024>',
		:thumbnails => { 
			:tiny => '35x45',
			:small => '70x90',
			:medium => '140x180',
			:large => '280x360'
		}
		# :cropped => '4:3 aspect ratio'
		
  validates_as_attachment


#   def resize_image(img, size)
#     # Get rid of all colour profiles.  They take up a lot of space.
#     img.strip
#     img.quality 60
#     super
#   end
# 

  def preview_filename
    # RAILS_ROOT + '/public' + self.public_filename
    RAILS_ROOT + '/montage.jpg'
  end
  
  def generate_preview
    fn = self.full_filename(:small)
    
    image = MiniMagick::Image.from_file(fn)
    image.run_command "montage #{fn} #{fn} #{fn} #{fn} #{fn} #{fn} -background #ffffff -tile 3x2 -geometry +1+1 montage.jpg"
  end
  
  def crop(width, height, x1, y1)
    image = MiniMagick::Image.from_file(self.full_filename(:large))
    image.crop "#{width}x#{height}+#{x1}+#{y1}"
    image.write(self.full_filename)
#    image.write(self.full_filename.gsub(/\.jpg/, '_cropped.jpg'))
  end
  
end
