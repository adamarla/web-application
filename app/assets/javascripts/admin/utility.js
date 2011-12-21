
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

