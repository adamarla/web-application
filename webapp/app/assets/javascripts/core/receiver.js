
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

  /* Events & Conditions the #side-panel is supposed to respond to */ 
  $('#side-panel').ajaxSuccess( function(e,xhr,settings) {
    var json = $.parseJSON(xhr.responseText) ;

    if (settings.url.match(/schools\/list/) != null) { 
      // First, clear any previous data
      $(this).find('.clear-before-show').each( function() { $(this).empty() ; } ) ;
      displaySchoolListInSidePanel( json.schools ) ;
    } else if (settings.url.match(/courses\/list/) != null) {
      // First, clear any previous data
      $(this).find('.clear-before-show').each( function() { $(this).empty() ; } ) ;
      displayCoursesListInSidePanel( json.courses ) ;
    } else if (settings.url.match(/yardsticks\/list/) != null) {
      // First, clear any previous data
      $(this).find('.clear-before-show').each( function() { $(this).empty() ; } ) ;
      displayYardsticksInSidePanel( json.yardsticks ) ;
    } 

  }) ;

  /* Events & Conditions #middle-panel is supposed to respond to */ 
  $('#middle-panel').ajaxSuccess( function(e, xhr, settings) { 
    var json = $.parseJSON(xhr.responseText) ;


    if (settings.url.match(/yardstick\.json\?id=/) != null) { // a GET request
      uncheckAllCheckBoxesWithin('#edit-yardstick') ;
      loadFormWithJsonData( $('#edit-yardstick > form.formtastic'), json.yardstick) ;
    } else if (settings.url.match(/teachers\/list/) != null) {
      displayTeachersListInX( json.teachers, '#teachers-list') ;
    } 
  }) ;

  /* Events & Conditions #right-panel is supposed to respond to */ 
  $('#right-panel').ajaxSuccess( function(e, xhr, settings) { 
  });

  /* Events & Conditions #wide-panel is supposed to respond to */ 
  $('#wide-panel').ajaxSuccess( function(e, xhr, settings) { 
    var json = $.parseJSON(xhr.responseText) ;

    if (settings.url.match(/course\.json\?id=/) != null) { // a GET request
      arrangeDumpIntoColumns('#edit-syllabi-megaform > form:first') ;
      uncheckAllCheckBoxesWithin('#edit-syllabi-megaform') ;
      disableAllSelectsWithin('#edit-syllabi-megaform') ;
      loadSyllabiEditFormWith(json.course.syllabi) ;
    } 
  }) ;

}) ;
