
/*
  Update #schools-summary with the returned JSON data (data)
*/ 

function updateSchoolSummary( data ) {
  $.each(data.schools, function(index,hash){
    var school = hash.school ; 
    var columns = [ [null,'radio',school.id],
                    [school.name,'regular'], 
                    [school.address,'wide'],
                    [school.zip_code,'narrow'],
                    [school.phone,'regular'],
                    [school.email,'wide overflow'] ] ;

    var row = createTableRow(columns) ;
    
    row.appendTo('#schools-summary .data:first') ; 
    setCellSizesIn(row) ;
    if (index % 2 == 1) { 
      row.addClass('colored') ;
    } 
    row.hide().fadeIn('slow') ;
  }) ;
}

/*
  Update #courses-summary with the returned JSON data (data)
*/ 

function updateCourseSummary( data ) {
  $.each(data.courses, function(index,hash){
    var course = hash.course ; 
    var columns = [ [null,'radio',course.id],
                    [course.name,'wide'], 
                    [course.board,'narrow'],
                    [course.klass,'narrow'],
                    [null,'narrow'] ] ;

    var row = createTableRow(columns) ;
    
    row.appendTo('#courses-summary .data:first') ; 
    setCellSizesIn(row) ;
    if (index % 2 == 1) { 
      row.addClass('colored') ;
    } 
    row.hide().fadeIn('slow') ;
  }) ;
}

function displaySchoolListInSidePanel( schools ) {

  $.each( schools, function(index, data) {
    var school = data.school ; 
    var clone = $('#toolbox .radio-column:first').clone() ;
    var radio = clone.children('.radio:first') ;
    var label = clone.children('.content:first') ;

    /*
      Refer toolbox/radio_one_column.haml

      We need to set the following on the newly cloned element : 
        1. 'url' attribute on the radio-button 
        2. Text for the sibling <div> 
        3. 'colored' attribute on every alternate row 
        4. Uncheck the radio button
        5. Set 'marker' attribute on the radio button
    */ 

    radio.attr('url', 'school.json?id=' + school.id) ; // url = school.json?id=4
    radio.attr('marker', school.id) ;
    radio.prop('checked', false) ;
    label.text( school.name ) ;

    if (index % 2 == 1) clone.addClass('colored') ;
    clone.appendTo('#schools-summary > .data:first').hide().fadeIn('slow') ;
  }) ;
  
} 

