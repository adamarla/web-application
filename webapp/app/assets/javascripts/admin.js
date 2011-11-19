// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( function() { 
	$('#new-benchmark-button').click( function() { 
		$('#new-grade-description').dialog({
			modal : true, 
			title : "Define New Benchmark",
			autoOpen : false 
		}).dialog('open');
	}) ;
}) ;
