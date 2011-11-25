
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

function createTableRow( rowCells ) { 
  // Each element in 'rowCells' is either a pair or a triplet, where : 
  //   1st = display text (mandatory)
  //   2nd = class attribute to set on table cell (mandatory) 
  //   3rd = some other non-display data, set as marker=< something > (optional)
  // Return : A jQuery <div class=row>.... </div>

  var row = $('<div class="row"></div>') ;

  $.each(rowCells, function(index, cell){
    var value = cell[0] ; 
    var classAttr = cell[1] ; 
    var marker = cell[2] ;


    // <div class="cell wide"></div>
    var str = '<div class="cell ' + classAttr + '"></div>' ; 
    var newElement = $(str) ;

    if (marker != nil){ 
      newElement.attr('marker', marker) ;
    } 

    if (classAttr != 'quick-link') {
      // <div class="cell wide">Something, something</div>
      newElement.text(value) ;
    } else { 
      // <div class="cell quick-link"><a href="#" mark=3>Edit</a></div>
      var anchor = $('<a href="#" marker="' + marker + '">Edit</a>') ;

      newElement.append(anchor) ;
    } 
    $(row).append(newElement) ;
  }) ;
  return row ;
} 

function fitIntoWidth( widthInPx, object ){
  // Returns newly calculated with value (in px). Maintains object's borders, 
  // margins and paddings 

  margin = $(object).outerWidth(true) - $(object).outerWidth(false) ; 
  border = $(object).outerWidth(false) - $(object).innerWidth() ; 
  padding = $(object).innerWidth() - $(object).width() ;

  return (widthInPx - margin - border - padding) ;
} 
