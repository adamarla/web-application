/*
  Define only those bindings here that would apply across all roles. 

  These bindings would apply to HTML elements with class, id or other 
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
*/ 

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



$( function() { 
    // Generally speaking, contain all forms first inside a <div> and call 
    // .dialog() only on this <div>. And if you want the resulting dialog to 
    // close whenever the submit button is clicked ( if there is one and 
    // whatever it might be ), then assign class="close-on-submit" attribute to the <div>

    $('.close-on-submit').ajaxSend( function() { 
        $(this).dialog('close') ;
    }) ; 

    // Group individual forms into one accordion...  
    $('.form.accordion').accordion({ header : '.heading.accordion', collapsible : true, active : false }) ;
    // .. and let the accordion shut like a clam before sending an AJAX request
    $('.form.accordion').ajaxSend( function() {
        $(this).accordion('activate', false) ;
    }) ;

    // Button-set for submit buttons
    $('.submit-buttons').buttonset() ;

    // $('#board-list').buttonset() ;
    
    $('.action-panel.vertical').each( function() {
       alignVertical( $(this) ) ;
    }) ;

    /*
       Expand 'greedy' elements so that they take all remaining 
       width in their parent
    */ 

    $('.greedy').each( function() { 
        makeGreedy($(this)) ;
    }) ;

    /*
      Load controls in the #control-panel when a link in the #side-panel is clicked.
      Also, load the empty table - that is, just the headers - in #tables into #data-panel

      However, logic for loading any relevant data into #data-panel would 
      most probably be in the role-specific .js file and would require a separate 
      binding to the same elements listed below
    */

    $('.main-link > a').click( function() { 
      var controls = $(this).attr('load_on_click') ;
      var table = $(this).attr('load_table') ;
      
      /*
        Move any previous controls in #control-panel to #controls.hidden.
        Then move 'controls' to #control-panel w/ fade-in effect
      */ 
      if (controls != null) { 
        var previous = $('#control-panel').children().first() ;

        if (previous.length == 1){
          // previous.removeClass('greedy') ;
          previous = previous.detach() ; 
          previous.appendTo($('#controls')) ;
        } 
        // $(controls).addClass('greedy') ;

        $(controls).appendTo('#control-panel').hide().fadeIn('slow') ; 
        makeGreedy( $(controls) ) ;
      }

      /* 
        Similarly, move any previous table in #data-panel to #tables.hidden
        and then the new 'table' to #data-panel. However, this time, empty 
        the first table first before moving it to #tables.hidden. We don't 
        want any residual data for next time
      */ 

      if (table != null) { 
        var previous = $('#data-panel').children().first() ;

        if (previous.length == 1) { 
          previous.children('.data').first().empty() ; // empty only the data, not the headers
          previous = previous.detach() ; 
          previous.appendTo($('#tables')) ;
        } 
        $(table).appendTo('#data-panel').hide().fadeIn('slow') ;
        makeGreedy( $(table) ) ;
      } 

    }) ; // end 

    /*
      Count the number of columns for all tables. The count is important 
      for dynamic resizing of table columns. Static class attribute values - like 
      wide, regular & narrow - are not sufficient by themselves for telling us 
      what the width should be. If, however, they were to be used to specify relative 
      width ratios, then they might be useful
    */ 

    $('.table').each( function() { 
      countTableColumns($(this)) ;
      calculateColumnWidths($(this)) ;
    }) ; 

}) ; // end of file ...


