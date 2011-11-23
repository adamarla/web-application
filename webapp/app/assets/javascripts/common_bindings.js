
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
    

}) ; 


