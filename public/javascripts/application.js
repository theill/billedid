if ( /AppleWebKit|MSIE/.test( navigator.userAgent ) ) {
	Event.addBehavior({
		'form:submit' : function( e ){
			if ( Event.element( e ).getElementsBySelector("input[file]") ) {
				new Ajax.Request("/ping/close", { asynchronous:false });	
			}
	  }
	});
}

Event.onReady( function(){
	var pageTracker = _gat._getTracker("UA-869742-15");
	pageTracker._trackPageview();
});

Event.observe(window, 'load', function() {
	if ($('photo-image')){
		new Cropper.ImgWithPreview(
			'photo-image', {
/*				previewWrap: 'photo-preview',*/
				minWidth: 70,
				minHeight: 90,
				ratioDim: {
					x: 70, 
					y: 90
				},
				displayOnInit: true,
				onEndCrop: onEndCrop
			}
		);	
	}
});
	
function onEndCrop(coords, dimensions) {
	$('x1').value = coords.x1;
	$('y1').value = coords.y1;
	$('x2').value = coords.x2;
	$('y2').value = coords.y2;
	$('width').value = dimensions.width;
	$('height').value = dimensions.height;
}
