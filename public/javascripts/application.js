// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
if ( /AppleWebKit|MSIE/.test( navigator.userAgent ) ) {
	Event.addBehavior({
		'form:submit' : function( e ){
			if ( Event.element( e ).getElementsBySelector("input[file]") ) {
				new Ajax.Request("/ping/close", { asynchronous:false });	
			}
	  }
	});
}
