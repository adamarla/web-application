// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$( function() { 

    // New Yardstick 
    $('#new-yardstick-button').click( function() { 
        $('#new-yardstick').dialog({
            modal : true, 
            title : "New Yardstick",
            autoOpen : false 
        }).dialog('open');
    }) ;

    // New School Board 
    $('#new-school-board-link').click( function() {
        $('#new-board-form').dialog({
            modal : true, 
            title : "New School Board", 
            autoOpen : false
        }).dialog('open') ;
    }) ;

    /* New Course
    $('#new-course-link').click( function() {
        $('#new-course-form').dialog({
          modal : true,
          title : "New Course", 
          autoOpen : false
        }).dialog('open') ;
    }) ;
    */

    $('#new-course-link').click( function() {
        var appendable = $('#new-board-form .appendable') ;
        var next = parseInt($(appendable).attr('next')) + 1 ;
        
        // First, make a stub element
        var clone = $('#new-course-form .extractable').clone() ; 
        var stub = $('<div class="stub"></div>').prepend($(clone));

        // Then, prepend the stub within appendable. Remember to increment i
        // appendable's next counter 
        $(stub).prependTo($(appendable)).hide().fadeIn('slow') ;
        $(appendable).attr('next', next) ; 

        // This is  really important. Set the 'name' attribute for <input> and 
        // <select> within the newly added stub

        $(stub).find('input,select').each( function() {
            var name = $(this).attr('name') ;
            // 'name' is of the form : courses[*][ grade | subject_id ... ]. The '*'
            // has to be replaced with the current 'next'
            name = name.replace(/\*/g, next) ; 
            $(this).attr('name', name) ;
        }) ;
    }) ; // of function

}) 
