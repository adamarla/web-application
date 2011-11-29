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

	/*

    // New Course with the option of simultaneously adding some Courses
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
            name = name.replace(/\/g, next) ; 
            $(this).attr('name', name) ;
        }) ;
    }) ; // of function


    // on-the-fly loading of Courses for a selected Board 
    $('#board-list input[type="radio"]').click( function() { 
      var marker = $(this).attr('marker') ; 
      var url = "/get_course_details/" + marker ;

      $.get(url, function(data){
        var courses = data.board.courses ; 

        $('#courses-table .data:first').empty() ; // empty old table content

        $.each( courses, function(index, hash) { 
           var course = hash.course ; 
           var cells = [] ; 

           // Push a triplet where : 
           //   1st = display text
           //   2nd = class attribute to set on table cell
           //   3rd = some other relevant, non-display data
           cells.push(["edit", "quick-link", course.id]) ;
           cells.push([course.name, "wide", null]) ; 
           cells.push([course.subject.name, "regular", null]) ; 
           cells.push([course.grade, "narrow", null]) ; 

           // alert(" Course ID = " + course.id) ;
           var tableRow = createTableRow( cells ) ;

           tableRow.addClass('greedy') ;
           if (index % 2 == 1) { 
             $(tableRow).addClass('color') ;
           } 

           // Now insert the row inside $('#courses-table') 
           $('#courses-table .data:first').append( tableRow ).hide().fadeIn('slow') ;

        }) ; 
      }, "json") ;
    }) ; // end 
	*/

}) ; 
