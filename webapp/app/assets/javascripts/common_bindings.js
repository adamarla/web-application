
$( function() { 
    // Generally speaking, contain all forms first inside a <div> and call 
    // .dialog() only on this <div>. And if you want the resulting dialog to 
    // close whenever the submit button is clicked ( if there is one and 
    // whatever it might be ), then assign class="close-on-submit" attribute to the <div>

    $('.close-on-submit').ajaxSend( function() { 
        $(this).dialog('close') ;
    }) ; 

    // Group individual forms into one accordion...  
    $('.form.accordion').accordion({ header : '.heading.accordion', collapsible : true, active : false }) ;
    // .. and let the accordion shut like a clam before sending an AJAX request
    $('.form.accordion').ajaxSend( function() {
        $(this).accordion('activate', false) ;
    }) ;

    // Button-set for submit buttons
    $('.submit-buttons').buttonset() ;

    // $('#board-list').buttonset() ;
    
    $('.action-panel.vertical').each( function() {
       alignVertical( $(this) ) ;
    }) ;

    $('#board-list input[type="radio"]').click( function() { 
      var index = $(this).attr('index') ; 
      var url = "/get_course_details/" + index ;

      $.get(url, function(data){
        var courses = data.board.courses ; 

        $('#courses-table table .table.content').empty() ; // empty old table content

        $.each( courses, function(index, hash) { 
           var course = hash.course ; 
           var rowElements = [] ; 

           rowElements.push(course.name) ; 
           rowElements.push(course.subject.name) ; 
           rowElements.push(course.grade) ; 
           rowElements.push(course.active) ; 

           var tableRow = createTableRow( rowElements ) ;

           if (index % 2 == 1) { 
             $(tableRow).addClass('color') ;
           } 

           // Now insert the row inside $('#courses-table') 
           $('#courses-table table tbody').append( tableRow ).hide().fadeIn('slow') ;

        }) ; 
      }, "json") ;
    }) ;
    

}) ; 


