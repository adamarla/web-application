
function displayJson(jsonArray, where, key, withRadioButtons) 
{
   withRadioButtons = (withRadioButtons == undefined) ? true : withRadioButtons ;

   $.each(jsonArray, function(index, data) {
     var clone = (withRadioButtons) ? createOneRadioColumnForX(data, key) : 
                                      createOneCheckBoxColumnForX(data, key) ;
     if (index % 2 == 1) clone.addClass('colored') ;
     clone.appendTo(where).hide().fadeIn('slow') ;
   }) ;
} 

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

function displayTeachersListInX( teachers, X ) {
  $.each( teachers, function(index, data) {
    var clone = createOneRadioColumnForX(data, 'teacher', 'teachers/roster') ;
    if (index % 2 == 1) clone.addClass('colored') ;
    clone.appendTo( X + ' > .data:first').hide().fadeIn('slow') ;
  }) ; 
}

function displayStudyGroups( sections, X, checkBoxes) {
  checkBoxes = (checkBoxes == undefined) ? false : checkBoxes ;

  $.each(sections, function(index, data) {
    var clone = (checkBoxes) ? createOneCheckBoxColumnForX(data, 'section') : 
                               createOneRadioColumnForX(data, 'section') ;
    if (index % 2 == 1) clone.addClass('colored') ;
    clone.appendTo(X).hide().fadeIn('slow') ;
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

