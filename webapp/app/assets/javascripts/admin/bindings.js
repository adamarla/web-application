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

}) ; // end of main 
