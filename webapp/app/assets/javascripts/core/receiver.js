
/* 
   This is a bloody important file. 

   Everytime there is an AJAX request, and therefore an AJAX response, 
   the response needs to be captured and if something needs to be done 
   by an element, then that something must be done

   It is this internal wiring that is defined here. 

   Broadly speaking, rather than attach event handlers to, say, a radio
   button - of which there would be many - we prefer to attach one 
   event handler to a DOM element high up in the DOM hierarchy. In the 
   new jQuery ( > 1.7 ), events percolate up the DOM and are captured 
   by the first element tasked to do so. The advantage is a leaner in-memory 
   object model.
*/ 


$( function() { 

  $('#side-panel').ajaxSuccess( function(e,xhr,settings) {
    var json = $.parseJSON(xhr.responseText) ;

    if (settings.url.match(/schools\/list/) != null) { 
      // First, clear any previous data
      $(this).find('.data:first').empty() ;
      displaySchoolListInSidePanel( json.schools ) ;
    } 

  }) ;

}) ;
