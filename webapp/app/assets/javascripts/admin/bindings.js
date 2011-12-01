/*
  Bindings specific to the Admin role
*/ 

$(function() { 
  
  /*
    When links in the #side-panel are clicked ... 
  */ 
  $('#boards-link > a').click( function() { $.get('boards/summary') ; }) ;
  $('#courses-link').click( function() { $.get('courses/list') ; }) ;

  /*
    When the 'yardsticks' link in the side-panel is clicked 
  */ 

  $('#yardsticks-link').click( function() { 
    var url = 'yardsticks/list' ; // Ref : views/yardsticks/list.json.rabl

    $.get(url, function(data) {
      $.each(data.yardsticks, function(index, hash){
        var yardstick = hash.yardstick ; 
        var columns = [ [null,'radio',yardstick.id], 
                        [yardstick.annotation,'regular'],
                        [yardstick.description,'wide'],
                        [yardstick.mcq, 'narrow'],
                        [yardstick.subpart,'narrow'] ] ;

        var row = createTableRow(columns) ; 

        setCellSizesIn(row) ;
        row.appendTo('#yardsticks-summary .data:first') ;
        if (index % 2 == 1) { 
          row.addClass('colored') ;
        } 
        row.hide().fadeIn('slow') ;
      }) ;
    }) ; 

  }) ;

  /*
    When the 'schools' link in the side-panel is clicked
  */ 
  $('#schools-link').click( function() { 
    // Refer : views/schools/list.json.rabl
    var url = 'schools/list' ; 

    $.get(url) ;
  }) ;

  /*
    Add a new School to the DB 
  */ 

  $('#add-school-link').click( function() { 
    $('#new-school').dialog({ title : 'Add School'}).dialog('open') ; 
  }) ; 

  /*
    Add a new Course to the DB
  */ 
  $('#add-course-link').click( function() {
    $('#new-course').dialog({ title : 'Add Course'}).dialog('open') ;
  }) ;

  /*
    Part II : When radio buttons in a summary table are clicked, then they 
    should update links in #control-panel using their 'marker' attribute. The 
    base behaviour of de-selecting other radio buttons is implemented in 
    shared/bindings.js
  */ 

  /* Schools */
  $('#data-panel').on('click', '#schools-summary .data .row > .radio', function() { 
    var marker = $(this).attr('marker') ;

    $('#edit-school-link').attr('marker', marker) ;
    $('#view-teachers-link').attr('marker', marker) ;
  }) ;

  $('#control-panel').on('click','#edit-school-link', function() { 
    var marker = $(this).attr('marker') ; 
    var url = 'school.json?id=' + marker ;
    var form = $('#edit-school form.formtastic') ;

    if (form.length == 0) { 
        alert (' form not found ') ;
        return ;
    } 

    $.get(url, function(data) {
      loadFormWithJsonData( form, data.school ) ;
      editFormAction('#edit-school', url, 'put') ;
      $('#edit-school').dialog('open') ;
    }) ;

  }) ;

  /* Courses */
  $('#data-panel').on('click', '#courses-summary .data .row > .radio', function() { 
    var marker = $(this).attr('marker') ;

    $('#edit-course-link').attr('marker', marker) ;
    $('#edit-syllabus-link').attr('marker', marker) ;
  }) ;

  $('#control-panel').on('click','#edit-course-link', function() { 
    var marker = $(this).attr('marker') ; 
    var url = 'course.json?id=' + marker ;
    var form = $('#edit-course form.formtastic') ;

    if (form.length == 0) { 
        alert (' form not found ') ;
        return ;
    } 

    $.get(url, function(data) {
      loadFormWithJsonData( form, data.course ) ;
      editFormAction('#edit-course', url, 'put') ;
      $('#edit-course').dialog('open') ;
    }) ;

  }) ;

  /* When #edit-syllabus-link is clicked */ 
  $('#edit-syllabus-link').click( function() { 
    var marker = $(this).attr('marker') ; 
    var table = $('#syllabus') ;

    replaceControlPanelContentWith('#topic-controls') ;

    replaceDataPanelContentWith('#edit-syllabi-megatable') ;
    arrangeDumpIntoColumns('#edit-syllabi-megatable') ;
  }) ;

  /* Add a new Specific Topic */ 
  $('#add-topic-link').click( function() { 
    $('#new-topic').dialog({ title : 'New Topic' }).dialog('open') ;
  }) ; 


}) ; // end of main 
