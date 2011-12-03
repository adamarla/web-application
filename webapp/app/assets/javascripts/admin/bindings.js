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
    displayMegaForm('#edit-yardsticks-megaform') ;
  }) ;
  /*

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

    if (marker == null) { 
      alert (" Please select a course first " ) ;
      return ; 
    } 

    // #course-summary .radio -> #edit-syllabus-link -> #edit-syllabi-megaform -> hidden <input>
    $('#edit-syllabi-megaform > form > input.hidden:first').val(marker) ;
    $(this).attr('marker', null) ; 
    // reset to force re-clicking of radio button in #course-summary

    replaceControlPanelContentWith('#topic-controls') ;
    uncheckAllCheckBoxesWithin('#edit-syllabi-megaform') ;
    disableAllSelectsWithin('#edit-syllabi-megaform') ;

    displayMegaForm('#edit-syllabi-megaform') ;
    
    /*
      Now, get syllabus information for the course. Code for updation - 
      using the returned data - is in admin/utility.js
    */ 
    var url = 'syllabus.json?course_id=' + marker ; 
    $.get(url) ;
  }) ;

  /* 
    Load returned JSON data into #edit-syllabi-megaform. 
    All checkboxes are unchecked and all selects disabled at this point
  */ 

  $('#edit-syllabi-megaform').ajaxSuccess( function(e,xhr,settings) {
    if (settings.url.match(/syllabus\.json\?course_id/) == null) return ;

    var json = $.parseJSON(xhr.responseText) ;
    var syllabi = json.syllabi ;
    var table = $(this) ;

    $.each(syllabi, function(index, data){
      // data = {syllabus : {specific_topic_id : 10, difficulty : 3}}
      var topic_id = data.syllabus.specific_topic_id ; 
      var difficulty = data.syllabus.difficulty ;
      var targetDiv = table.find('div[marker=' + topic_id + ']') ; // <div marker='10'> 

      if (targetDiv.length == 0) return ; 

      var checkBox = targetDiv.children('.checkbox:first').children('input:first') ;
      var dropDown = targetDiv.children('.dropdown:first').find('select:first') ;
      var option = dropDown.children('option[value=' + difficulty + ']:first') ;

      checkBox.prop('checked', true) ; 
      dropDown.prop('disabled', false) ;
      option.prop('selected', true) ;
      
    }) ;
  }) ;

  /* Add a new Specific Topic */ 
  $('#add-topic-link').click( function() { 
    $('#new-topic').dialog({ title : 'New Topic' }).dialog('open') ;
  }) ; 

  /* 
    In #edit-syllabi-megaform, enable drop downs ONLY IF the sibling
    checkbox is checked 
  */ 

  $('#edit-syllabi-megaform').on('click', '.column input[type="checkbox"]', function() {
    var dropDown = $(this).parent().siblings('.dropdown:first').find('select:first') ;

    dropDown.prop('disabled', !($(this).prop('checked')) ) ;
  }) ;


}) ; // end of main 
