/*
  Bindings specific to the Admin role
*/ 

$(function() { 
  
  $('#schools-link').click() ;
  
  /*
    When links in the #control-panel are clicked ... 
  */ 
  $('#boards-link > a').click( function() { $.get('boards/summary') ; }) ;
  $('#courses-link').click( function() { $.get('courses/list') ; }) ;

  /*
    When the 'yardsticks' link in the control-panel is clicked 
  $('#yardsticks-link').click( function() { 
    displayMegaForm('#edit-yardsticks-megaform') ;
  }) ;
  */ 

  $('#yardsticks-link').click( function() { 
    $.get('yardsticks/list') ;
  }) ;

  /*

  /*
    When the 'schools' link in the control-panel is clicked
  */ 
  $('#schools-link').click( function() { 
    // Refer : views/schools/list.json.rabl
    var url = 'schools/list' ; 

    $.get(url) ;
  }) ;

  /*
    Add a new School to the DB 

  $('#add-school-link').click( function() { 
    $('#new-school').dialog({ title : 'Add School'}).dialog('open') ; 
  }) ; 
  */ 

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
    core/behaviour.js
  */ 

  /* Schools */
  $('#schools-summary').on('click', '#schools-summary .data input[type="radio"]', function() { 
    var marker = $(this).attr('marker') ;

    $('#edit-school-link').attr('marker', marker) ;
    $('#view-teachers-link').attr('marker', marker) ;
  }) ;

  /*
    When a radio-button in #yardsticks-summary is clicked, it should change the 
    'action' attribute of the edit form that opens alongside
  */ 

  $('#yardsticks-summary').on('click', 'input[type="radio"]', function() {
    var marker = $(this).attr('marker') ;
    editFormAction('#edit-yardstick', '/yardstick?id=' + marker, 'put') ;
  }) ;

  /*
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
  */

  $('#edit-course-link').click( function() { 
     // If #edit-course-link is visible, then it means #side-panel is showing
     // #courses-summary. And if a radio button has been selected in the latter, 
     // then #side-panel has corresponding marker set on it

     var marker = $('#side-panel').attr('marker') ;

     if (marker == null){ 
       alert ( " Please select a course first ") ;
       return ;
     } 

     var url = 'courses/load.json?id=' + marker ;
     $.get(url, function(data) {
       var form = $('#edit-course > form.formtastic') ;

       loadFormWithJsonData(form, data.course) ;
       editFormAction('#edit-course', 'course?id=' + marker, 'put') ;
       $('#edit-course').dialog('open') ;
     }) ;
  }) ;

  /* Courses */
  /*
  $('#courses-summary').on('click', 'input[type="radio"]', function() {
  } 

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
  */

  /* 
    Load returned JSON data into #edit-syllabi-megaform. 
    All checkboxes are unchecked and all selects disabled at this point
  */ 

  /* Add a new Specific Topic */ 
  $('#add-topic-link').click( function() { 
    $('#new-topic').dialog({ title : 'New Topic' }).dialog('open') ;
  }) ; 

  /* 
    In #edit-syllabi-megaform, enable drop downs ONLY IF the sibling
    checkbox is checked 
  */ 

  $('#edit-syllabi-megaform').on('click', '.checkbox > input[type="checkbox"]', function() {
    var dropDown = $(this).closest('div[marker]').children('.dropdown:first').find('select:first') ;

    dropDown.prop('disabled', !($(this).prop('checked')) ) ;
  }) ;


}) ; // end of main 
