
/*
  Define any and all overrides here. Examples would include changing 
  the action attribute of forms generated using formtastic. The rule of 
  thumb is that any attribute, in any DOM element, that needs a different
  value from the one assigned to it at the time of creation, should be 
  over-ridden here
*/ 

$( function() {
    /*
	  Some of the forms generated using formtastic would need 
	  their 'action' and/or 'method' attributes redefined. Do that now... 
	*/ 
	editFormAction('#new-school', '/school') ; 
	editFormAction('#new-course', '/course') ;

}) ;
