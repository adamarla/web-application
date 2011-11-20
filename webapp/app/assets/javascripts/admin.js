// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( function() { 
	$('#new-yardstick-button').click( function() { 
		$('#new-yardstick').dialog({
			modal : true, 
			title : "New Yardstick",
			autoOpen : false 
		}).dialog('open');
	}) ;
}) ;
