
/*
// Update #schools-summary with the returned JSON data (data)

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

// Update #courses-summary with the returned JSON data (data)

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
*/

function displaySchoolListInSidePanel( schools ) {
  $.each( schools, function(index, data) {
    var clone = createOneRadioColumnForX(data, 'school') ;
    if (index % 2 == 1) clone.addClass('colored') ;
    clone.appendTo('#schools-summary > .data:first').hide().fadeIn('slow') ;
  }) ;
} 

function displayCoursesListInSidePanel( courses ) {
  $.each( courses, function(index, data) {
    var clone = createOneRadioColumnForX(data, 'course') ;
    if (index % 2 == 1) clone.addClass('colored') ;
    clone.appendTo('#courses-summary > .data:first').hide().fadeIn('slow') ;
  }) ;
} 

function displayYardsticksInSidePanel( yardsticks ) { 
  $.each( yardsticks, function(index, data) { 
    var clone = createOneRadioColumnForX(data, 'yardstick') ;

    // Colour the rows based on the yardsticks applicability to sub-parts and mcqs
    if (data.yardstick.mcq) {
      clone.addClass('light-orange') ;
    } else if (data.yardstick.subpart) {
      clone.addClass('light-green') ;
    } 
    clone.appendTo('#yardsticks-summary > .data:first').hide().fadeIn('slow') ;
  }) ;
} 

function displayTeachersListInX( teachers, X ) {
  $.each( teachers, function(index, data) {
    var clone = createOneRadioColumnForX(data, 'teacher', 'teacher/roster') ;
    if (index % 2 == 1) clone.addClass('colored') ;
    clone.appendTo( X + ' > .data:first').hide().fadeIn('slow') ;
  }) ; 
}

function loadSyllabiEditFormWith(syllabi) {
  var table = $('#edit-syllabi-megaform') ;

  $.each(syllabi, function(index, data){
    // data = {syllabus : {specific_topic_id : 10, difficulty : 3}}
    var topic_id = data.syllabus.specific_topic_id ; 
    var difficulty = data.syllabus.difficulty ;
    var targetDiv = table.find('div[marker=' + topic_id + ']') ; // <div marker='10'> 

    if (targetDiv.length == 0) return ; 

    var checkBox = targetDiv.find('.checkbox:first').children('input:first') ;
    var dropDown = targetDiv.find('.dropdown:first').find('select:first') ;
    var option = dropDown.find('option[value=' + difficulty + ']:first') ;

    checkBox.prop('checked', true) ; 
    dropDown.prop('disabled', false) ;
    option.prop('selected', true) ;
      
  }) ;
}

