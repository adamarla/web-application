
$( function() { 
	// Generate accordions 
	$('.accordion-form').accordion({ header : '.accordion-heading', collapsible : true, active : false }) ;

	// Stylize formtastic 'submit' buttons 
	$('input:submit').button() ;
}) ; 
