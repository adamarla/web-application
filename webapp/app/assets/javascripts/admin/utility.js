
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
                    [school.phone,'narrow'],
                    [school.email,'regular overflow'] ] ;

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
                    [course.grade,'narrow'],
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
