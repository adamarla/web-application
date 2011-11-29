/*
  Bindings specific to the Admin role
*/ 

$(function() { 
  
  /*
    When the 'boards' link in the side-panel is clicked
  */ 
  $('#boards-link > a').click( function() { 
    var url = 'boards/summary' ;

    $.get(url, function(data){
    }) ;

  }) ; 

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
    #add-school-link
  */ 

  $('#add-school-link').click( function() { 
    $('#new-school').dialog({ title : 'Add School'}).dialog('open') ; 
  }) ; 

  /*
    Part II : When radio buttons in #schools-summary are clicked, then they should update 
    links in #control-panel using their 'marker' attribute. The base behaviour of de-selecting
    other radio buttons is implemented in shared/bindings.js
  */ 

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

}) ; // end of main 
