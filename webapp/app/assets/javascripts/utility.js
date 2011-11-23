
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

function createTableRow( cellsWithClass ) { 
  // rowElements : A triplet where 
  //   1st = display text
  //   2nd = class attribute to set on table cell
  //   3rd = some other relevant, non-display data
  // Return : A jQuery <div class=row>.... </div>

  var row = $('<div class="row"></div>') ;

  $.each(cellsWithClass, function(index, cell){
    var value = cell[0] ; 
    var classAttr = cell[1] ; 
    var other = cell[2] ;


    // <div class="cell wide"></div>
    var str = '<div class="cell ' + classAttr + '"></div>' ; 
    var newElement = $(str) ;
    //alert(str) ;

    if (classAttr != 'quick-link') {
      // <div class="cell wide">Something, something</div>
      newElement.text(value) ;
    } else { 
      // <div class="cell quick-link"><a href="#" mark=3>Edit</a></div>
      newElement.append( $('<a href="#" marker="' + other + '">Edit</a>') ) ;
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
