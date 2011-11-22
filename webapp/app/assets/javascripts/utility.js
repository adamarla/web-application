
function alignVertical( radioButtons ) { 
  var bs = $(radioButtons).buttonset() ;

  $(bs).find('label:first').removeClass('ui-corner-left').addClass('ui-corner-top') ;
  $(bs).find('label:last').removeClass('ui-corner-right').addClass('ui-corner-bottom') ;

  var max_w = 0 ; 
  $('label', radioButtons).each( function() {
     var w = $(this).width() ; 
     max_w = (w > max_w) ? w : max_w ;
  }) ;

  $('label', radioButtons).each( function() {
     $(this).width(max_w) ;
  }) ;
} 

function createTableRow( rowElements ) { 
  // rowElements : An array of string 
  // Return : A jQuery <div class=row>.... </div>

  var row = $('<div class="row"></div>') ;

  $.each(rowElements, function(index, value){
    $(row).append($('<div class="data">' + value + '</div>')) ;
  }) ; 
  return row ;
} 
