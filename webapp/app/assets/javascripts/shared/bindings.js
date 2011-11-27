/*
  Define only those bindings here that would apply across all roles. 

  These bindings would apply to HTML elements with class, id or other 
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
*/ 

$( function() { 
    // Generally speaking, contain all forms first inside a <div class="new-entity"> and call 
    // .dialog() only on this <div>. And if you want the resulting dialog to 
    // close whenever the submit button is clicked ( if there is one and 
    // whatever it might be ), then assign class="close-on-submit" attribute to the <div>

    $('.new-entity').each( function() { 
      $(this).dialog({
        modal : true, 
        autoOpen : false
      }) ;
    }) ;

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
        Otherwise, move any previous controls in #control-panel to #controls.hidden.
        Then move 'controls' to #control-panel w/ fade-in effect
      */ 
      if (controls != null) { 
        var previous = $('#control-panel').children().first() ;

        if (previous.length == 1){
          previous = previous.detach() ; 
          previous.appendTo($('#controls')) ;
        } 
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
          previous.find('.data:first').empty() ; // empty only the data, not the headers
          previous = previous.detach() ; 
          previous.appendTo($('#tables')) ;
        } 
        $(table).appendTo('#data-panel').hide().fadeIn('slow') ;
        makeGreedy( $(table) ) ; 
        resizeCellsIn( $(table).children('.table').first() ) ;
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


