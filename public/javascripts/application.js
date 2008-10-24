if ( /AppleWebKit|MSIE/.test( navigator.userAgent ) ) {
	Event.addBehavior({
		'form:submit' : function( e ){
			if ( Event.element( e ).getElementsBySelector("input[file]") ) {
				new Ajax.Request("/ping/close", { asynchronous:false });	
			}
	  }
	});
}
