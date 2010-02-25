module ApplicationHelper

	# renders the top menu, allowing for links to the edit and show actions, if the passed session contains a photo_id and a cropped_photo_id
	def render_top_menu(path, session = nil)
		menuitems = content_tag :li, '<a href="/" title="Upload billede"><span>Upload</span></a>', :class => 'upload'

		if (session && !session[:photo_id].blank?)
			menuitems += content_tag :li, link_to( '<span>Tilpas</span>', edit_photo_path( session[:photo_id] ) ), :class => 'adjust'
		else
			menuitems += content_tag :li, '<span>Tilpas</span>', :class => 'adjust'
		end
		
		if (session && !session[:photo_id].blank? && !session[:cropped_photo_id].blank? && session[:photo_id] == session[:cropped_photo_id])
			menuitems += content_tag :li, link_to('<span>Download</span>', photo_path(session[:photo_id])), :class => 'download'
		else
			menuitems += content_tag :li, '<span>Download</span>', :class => 'download'
		end
		
		content_tag :ul, menuitems, :class => "nl active_step_#{ find_active_step( path, session ) }"
	end

	def render_meta_description(meta_description)
	  tag :meta, { :name => 'description', :content => h(meta_description) } unless meta_description.blank?
	end
	
	private
	
	def find_active_step( path, session = nil )
		active_step = case
		when session[:photo_id] && path == photo_path(session[:photo_id])
			3
		when session[:photo_id] && path == edit_photo_path(session[:photo_id])
			2
		when path == '/' || path == new_photo_path
			1
		else
			0
		end
	end

end