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
    When the 'schools' link in the side-panel is clicked
  */ 
  $('#schools-link > a').click( function() { 
    var url = 'schools/list' ; 

    // Refer : views/schools/list.json.rabl

    $.get(url, function(data) { 
      $.each(data.schools, function(index,hash){
        var school = hash.school ; 
        var columns = [ [null,'radio',school.id],
                        [school.name,'regular'], 
                        [school.address,'wide'],
                        [school.zip_code,'narrow'],
                        [school.phone,'narrow'],
                        [null,'regular'],
                        [school.email,'regular'] ] ;

        var row = createTableRow(columns) ;
        
        row.appendTo('#schools-summary .data:first') ; 
        setCellSizesIn(row) ;
        if (index % 2 == 1) { 
          row.addClass('colored') ;
        } 
        row.hide().fadeIn('slow') ;
      }) ;
    }) ;

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

}) ; // end of main 
