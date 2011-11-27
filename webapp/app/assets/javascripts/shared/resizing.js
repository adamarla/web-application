
function fitIntoWidth( widthInPx, object ){
  // Returns newly calculated with value (in px). Maintains object's borders, 
  // margins and paddings 

  margin = $(object).outerWidth(true) - $(object).outerWidth(false) ; 
  border = $(object).outerWidth(false) - $(object).innerWidth() ; 
  padding = $(object).innerWidth() - $(object).width() ;

  return (widthInPx - margin - border - padding) ;
} 

function makeGreedy(obj) {
  var parentWidth = obj.parent().width() ; // just the content
  var taken = 0 ; 

  obj.siblings().each( function() {
    var widthWithMargins = $(this).outerWidth(true) ;

    if (widthWithMargins < parentWidth){ // ignore any siblings with width = 100%
      taken += widthWithMargins ; 
    }
  }) ;

  var remaining = parentWidth - taken ; 
  var newWidth = fitIntoWidth(remaining, obj) - 1 ; // playing safe 
  
  /*
  alert("Me = " + obj.attr('id') + "\nParent = " + obj.parent().attr('id')
  + "\nParent Width = " + parentWidth + "\nRemaining = " + remaining + "\nNew = " + newWidth) ;
  */

  obj.outerWidth(newWidth) ;
}

