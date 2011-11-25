
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

function countTableColumns(table) { 
   /* 
     Every table in our app is of the form : 
        .table 
          .headings 
            .row 
              .cell .... 
          .data 
            .row 
              .cell ....
     We just count the number of .headings > .row > .cell and set value on the table
   */ 
   var nColumns = table.attr('num_columns') ;

   if (nColumns == null) { 
      nColumns = table.find('.headings .cell').length ;
      table.attr('num_columns', nColumns) ;
   } 
} 

function calculateColumnWidths(table) { 
  /*
    For the table like the one above, calculate % of parent width for a 
    wide, regular and narrow column. Aspect ratio = wide:regular:narrow = 3:2:1
  */
  var score = 0 ; 

  table.find('.headings .cell').each( function() { 
     if ($(this).hasClass('wide')) {
         score += 3 ;
     } else if ($(this).hasClass('regular')) {
         score += 2 ;
     } else if ($(this).hasClass('narrow')) {
         score += 1 ;
     } else { 
         score += 2 ;
     } 
  }) ; 

  table.attr('wide', 300/score ) ; 
  table.attr('regular', 200/score) ; 
  table.attr('narrow', 100/score) ; 

} // end 

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

function setCellSizesIn( row ) { 
  var table = $(row).closest('.table') ; 
  var parentWidth = $(row).parent().width() ; 

  var wide = (parseInt(table.attr('wide')) * parentWidth/100) ;
  var regular = (parseInt(table.attr('regular')) * parentWidth/100) ;
  var narrow = (parseInt(table.attr('narrow')) * parentWidth/100) ;

  // alert(" wide = " + wide + ", regular = " + regular + ", narrow = " + narrow) ;

  $(row).children().each( function() { // should be just .cells
    if ($(this).hasClass('wide')){
      $(this).width(wide) ;
    } else if ($(this).hasClass('regular')){
      $(this).width(regular) ;
    } else if ($(this).hasClass('narrow')) {
      $(this).width(narrow) ;
    } else { 
      $(this).width(regular) ;
    } 
  }) ; 
  
} // end  

function resizeCellsIn( table ) {
  alert (' wide = ' + table.attr('wide')) ;
  table.find('.headings > .row, .data > .row').each( function() {
    setCellSizesIn($(this)) ;
  }) ;
} 

