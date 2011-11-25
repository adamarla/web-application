/*
  This file contains functions that get bound to objects created on-the-fly. 
  Such objects will have no bindings right after creation. The only way
  then is to call .bind() on the newly created object explicitly

  Any bindings that can be applied on document loading should be placed in 
  'onload.js' only
*/ 

// Editing a course in a board - including the course -> specific-topic mapping
function editCourse() { 
  var marker = $(this).attr('marker') ; 
  var url = '/course.json?id=' + marker ; // see rake routes | grep course

  $.get(url, function(data){
    alert (" Called : " + url) ;
  }) ; 
} 
