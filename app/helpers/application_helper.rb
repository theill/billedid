module ApplicationHelper

	# <a href="/"><span>Upload</span></a></li>
	# <li class="adjust"><span>Tilpas</span></li>
	# <li class="download"><span>Download</span></li>


	def render_top_menu( path, session = nil )
		
		menuitems = content_tag :li, '<a href="/" title="Upload billede"><span>Upload</span></a>', :class => 'upload'
		if ( session && !session[:photo_id].blank? )
			menuitems += content_tag :li, link_to( '<span>Tilpas</span>', edit_photo_path( session[:photo_id] ) ), :class => 'adjust'
		else
			menuitems += content_tag :li, '<span>Tilpas</span>', :class => 'adjust'
		end
		
		# TODO: figure out how to make this a link, if the user has resized the photo
		menuitems += content_tag :li, '<span>Download</span>', :class => 'download'
		
		content_tag :ul, menuitems, :class => 'nl'
	end

end
