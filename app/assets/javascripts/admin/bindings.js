/*
  Bindings specific to the Admin role
*/ 

$(function() { 
  /*
    Add a new Course to the DB
  */ 
  $('#add-course-link').click( function() {
    $('#new-course').dialog({ title : 'Add Course'}).dialog('open') ;
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

       coreUtil.forms.loadJson(form, data.course) ;
       coreUtil.forms.modifyAction('#edit-course', 'course?id=' + marker, 'put') ;
       $('#edit-course').dialog('open') ;
     }) ;
  }) ;

  /* 
    In #edit-syllabi-megaform, enable drop downs ONLY IF the sibling
    checkbox is checked 

  $('#edit-syllabi-megaform').on('click', '.topic input[type="checkbox"]', function() {
    var dropDown = $(this).closest('div[marker]').children('.dropdown:first').find('select:first') ;

    dropDown.prop('disabled', !($(this).prop('checked')) ) ;
  }) ;
  */ 

  $('#view-students-in-section-link').click( function() { 
		sektion = $('#middle-panel').attr('marker') ;
    if (sektion != null) { 
      $.get('sektions/students.json?id=' + sektion) ;
    } 
  }) ;

  $('#view-unassigned-students-link').click( function() { 
    // Unassigned students only belong to a school. And therefore, the marker
    // we need is for the school, not a section (as above). This marker would 
    // be available on one of #control an #side panel

    var marker = $('#control-panel').attr('marker') ; 
    
    if (marker != null) { 
      $.get('school/unassigned-students.json?id=' + marker) ;
    } 
  }) ;


}) ; // end of main 
