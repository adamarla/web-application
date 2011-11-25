/*
  Define only those bindings here that would apply across all roles. 

  These bindings would apply to HTML elements with class, id or other 
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
*/ 


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

    // Expand 'greedy' elements so that they take all remaining width in their parent
    $('.greedy').each( function() {
      var parentWidth = $(this).parent().width() ; // just the content
      var taken = 0 ; 

      $(this).siblings().each( function() {
        var widthWithMargins = $(this).outerWidth(true) ;

        if (widthWithMargins < parentWidth){ // ignore any siblings with width = 100%
          taken += widthWithMargins ; 
        }
      }) ;

      var remaining = parentWidth - taken ; 
      var newWidth = fitIntoWidth(remaining, $(this)) - 1 ; // playing safe 

      /*
      alert("Me = " + $(this).attr('id') + "\nParent = " + $(this).parent().attr('id')
      + "\nParent Width = " + parentWidth + "\nRemaining = " + remaining + "\nNew = " + newWidth) ;
      */

      $(this).outerWidth(newWidth) ;
    }) ;

    /*
      Load controls in the #control-panel when a link in the #side-panel is clicked.
      However, logic for loading any relevant data into #data-panel would 
      most probably be in the role-specific .js file and would require a separate 
      binding to the same elements listed below
    */

    $('.main-link > a').click( function() { 
      var controls = $(this).attr('load_on_click') ;

      if (controls == null) return true ; 

      // Move any previous controls from #control-panel to #controls.hidden 
      var previous = $('#control-panel').children().first() ;

      if (previous.length == 1){
        previous = previous.detach() ; 
        previous.appendTo($('#controls')) ;
      } 

      // Then move 'controls' to #control-panel w/ fade-in effect
      $(controls).appendTo('#control-panel').hide().fadeIn('slow') ; 

    }) ; // end 

}) ; // end of file ...


