/*
  Define only those bindings here that would apply across all roles. 

  These bindings would apply to HTML elements with class, id or other 
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
*/ 

$( function() { 

    /*
      Stylize buttons in #admin-forms & #tables, but not #controls.
      The #control-panel is populated with stuff from #controls and styled buttons 
      are too big for the panel
    */ 
    $('#admin-forms input[type="submit"], #tables input[type="submit"]').button() ;
    /* 
      Generally speaking, contain all forms first inside a <div class="new-entity"> 
      and call .dialog() only on this <div>. And if you want the resulting dialog to 
      close whenever the submit button is clicked ( if there is one and whatever 
      it might be ), then assign class="close-on-submit" attribute to the <div>
    */

    $('.new-entity, .update-entity').each( function() { 
      $(this).dialog({
        modal : true, 
        autoOpen : false
      }) ;
    }) ;

    /*
      Dialogs that must close themselves when 'submit' - or similar - 
      button is clicked. Typically, these are dialogs that have a form in them
    */ 

    $('.close-on-submit').ajaxSend( function() { 
        $(this).dialog('close') ;
    }) ;

    /*

    // Group individual forms into one accordion...  
    $('.form.accordion').accordion({ header : '.heading.accordion', collapsible : true, active : false }) ;
    // .. and let the accordion shut like a clam before sending an AJAX request
    $('.form.accordion').ajaxSend( function() {
        $(this).accordion('activate', false) ;
    }) ;

    // Button-set for submit buttons
    $('.submit-buttons').buttonset() ;

    // $('#board-list').buttonset() ;
    */
    
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

    $('#side-panel').on('click', '#side-panel a.main-link', function() {
      var controls = $(this).attr('load-controls') ;
      var table = $(this).attr('load-table') ;

      replaceControlPanelContentWith(controls) ;
      replaceDataPanelContentWith(table) ;

      makeGreedy( $(table) ) ; 
      resizeCellsIn( $(table).children('.table').first() ) ;

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

    /*
      In tables where rows have radio-buttons, clicking on one radio-button
      should un-click all other radio buttons in the table. This what the 
      function below does. However, it assumes that tables are created using
      our standard structure, that is : 
         .table 
           .heading
             .
             . 
           .data 
             .row 
               .cell 
                 %input{ :type => :radio }
       
       Also, note that we are using what's called deferred binding. The radio buttons we 
       click are not present when the document first loads. Hence, click() wouldn't work.
       jQuery 1.7+ has a new, more efficient way of handling this using the new on() method
    */ 

    $('#data-panel').on('click', '.data > .row > .radio', function() { 
      var uncles = $(this).parent().siblings() ; // ok, technically grand-uncles.. 

      $(uncles).each( function() { 
        var cousins = $(this).children('.radio') ; // there might be >1 radio buttons/row 

        if (cousins.length == 0) return ;
        $(cousins).each( function() {
          $(this).children('input[type="radio"]:first').prop('checked', false) ;
        }) ;
      }) ;

      $(this).children('input[type="radio"]:first').prop('checked', true) ;
    }) ;

    /*
      In our forms, if a checkbox is checked, then it should submit 'true', 
      else 'false'. Note, that this is just how we interpret checkboxes. 
      The value really does not have to be only true/false. It could be 
      anything - my name, your name etc. etc.
    */ 

    $('form, .mega-form').on('click', "input[type='checkbox']", function() { 
      $(this).val( $(this).prop('checked') ) ;
    }) ;

    /*
      Updation of the same summary table can be triggered by many distinct events 
      spread across multiple DOM elements. And hence, rather than bind the updation 
      logic part to the triggering DOM element, it makes all the sense to bind 
      the logic to the table itself
    */ 

    $('.summary-table').ajaxSuccess( function(e, xhr, settings){
      var returnedJSON = $.parseJSON(xhr.responseText) ; 
      // alert(xhr.responseText) ;

      $(this).find('.table > .data').empty() ; // clear existing data first

      /*
        There are > 1 summary tables and all of them catch the AJAX success event.
        However, the success event was generated in a context and therefore not all
        tables are supposed to respond to it

        So that is what we do here. We check what the invoking URL was and then 
        which summary table needs to process any returned JSON data. For all other 
        tables, the execution should just fall through
      */ 

      if (settings.url.match(/schools\/list/) != null) { 
        if ($(this).attr('id') == 'schools-summary'){ // the capturing DOM element
          updateSchoolSummary(returnedJSON) ;
        } 
      } else if (settings.url.match(/courses\/list/) != null) {
        if ($(this).attr('id') == 'courses-summary'){ // the capturing DOM element
          updateCourseSummary(returnedJSON) ;
        } 
      } 

    }) ;


}) ; // end of file ...


