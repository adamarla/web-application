/*
  Bindings specific to the Admin role
*/ 

$(function() { 
  
  /*
    When links in the #control-panel are clicked ... 
  */ 
  $('#boards-link > a').click( function() { $.get('boards/summary') ; }) ;
  $('#courses-link').click( function() { $.get('courses/list') ; }) ;

  /*
    When the 'schools' link in the control-panel is clicked
  */ 
  $('#schools-link').click( function() { 
    // Refer : views/schools/list.json.rabl
    var url = 'schools/list' ; 

    $.get(url) ;
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
    core/behaviour.js
  */ 

  /* Schools */
  $('#schools-summary').on('click', 'input[type="radio"]', function() { 
    var marker = $(this).attr('marker') ;

    $('#edit-school-link').attr('marker', marker) ;
    $('#edit-roster-link').attr('marker', marker) ;
    $('#new-studygroups-link').attr('marker', marker) ;
    $('#edit-studygroups-link').attr('marker', marker) ;
  }) ;

  /*
    When a radio-button in #yardsticks-summary is clicked, it should change the 
    'action' attribute of the edit form that opens alongside
  */ 

  $('#yardsticks-summary').on('click', 'input[type="radio"]', function() {
    var marker = $(this).attr('marker') ;
  }) ;

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

  /*
    Editing faculty roster, that is, teacher <-> study-group mapping 
  */ 
  $('#edit-roster-link').click( function() { 
    // Even though the link is for editing faculty rosters, no editing
    // can happen until a faculty member is selected. Hence, just load the 
    // list of faculty members. Showing the actual roster would have to
    // wait for a second radio-button click 

    var teachers = 'teachers/list?school_id=' + $(this).attr('marker') ;
    $.get(teachers) ;
  }) ;

  $('#edit-studygroups-link').click( function() { 
    // As for 'edit-roster-link', the only thing that can be done on click
    // is loading the list of study-groups for the selected school ( as 
    // identified by the 'marker' set on $(this) and the list of students 
    // as yet unassigned to any study-group/section 

    var sections = 'school/sections.json?id=' + $(this).attr('marker') ;
    var unassigned = 'school/unassigned-students.json?id=' + $(this).attr('marker') ;

    $.get(sections) ;
    $.get(unassigned) ;
  }) ;

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

  $('#view-students-in-section-link').click( function() { 
    var panel = $(this).closest('.panel') ; // the containing panel
    var marker = (panel.length == 0) ? null : panel.attr('marker') ; 
    
    if (marker != null) { 
      clearPanel('#right-panel', false) ;
      $.get('study_groups/students.json?id=' + marker) ;
    } 
  }) ;

  $('#view-unassigned-students-link').click( function() { 
    // Unassigned students only belong to a school. And therefore, the marker
    // we need is for the school, not a section (as above). This marker would 
    // be available on one of #control an #side panel

    var marker = $('#control-panel').attr('marker') ; 
    
    if (marker != null) { 
      clearPanel('#right-panel', false) ;
      $.get('school/unassigned-students.json?id=' + marker) ;
    } 
  }) ;


}) ; // end of main 
