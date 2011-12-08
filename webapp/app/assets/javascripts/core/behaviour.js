
function panelXHasY( X, Y ) { // X, Y = CSS selectors 
  var child = $(X).children().first() ; 
  var id = (child.length == 0) ? null : child.attr('id') ; 

  if (id != null && id == Y) return true ; 
  return false ;
} 

function clearPanel( id ){ 
  var moveMe = $(id).children().first() ; 

  // If 'moveMe' has any data under a <div class="data"> within its 
  // hierarchy, then empty that data first. Note, it is assumed that there 
  // is *atmost one* .data element within any element and it has information
  // that can re-got from an AJAX query. In other words, if some data is 
  // too valuable to lose, then *do not* put it under .data

  var data = moveMe.find('.data:first') ;
  if (data != null) data.empty() ;

  moveMe = moveMe.detach() ; 
  moveMe.appendTo("#toolbox") ;
} 

/*
  Define only those bindings here that would apply across all roles. 

  These bindings would apply to HTML elements with class, id or other 
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
*/ 


$( function() { 
    /* Click #schools-link on load */ 
    // $('#schools-link').click() ;


    /*
      Stylize buttons in forms but not in the #control-panel. 
      The #control-panel is populated with stuff from #controls and styled buttons 
      are too big for that panel
    */ 
    $('#toolbox > div:not([class~="top-panel-controls"]) form input[type="submit"]').button() ;

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
      In our forms, if a checkbox is checked, then it should submit 'true', 
      else 'false'. Note, that this is just how we interpret checkboxes. 
      The value really does not have to be only true/false. It could be 
      anything - my name, your name etc. etc.
    */ 

    $('form, .mega-form').on('click', "input[type='checkbox']", function() { 
      $(this).val( $(this).prop('checked') ) ;
    }) ;


    /*
       Clicking on one radio-button should unclick all other 'sibling' radio buttons. 
       This is what the code below does. However, defining 'siblings' is tricky 
       given the infinite hierarchies that can be implemented. No code can address 
       the question completly for all situations. And so, this code makes the following 
       simplifying assumptions (shown below) - 1. there is a <div class="data"> element
       AND 2. all radio-buttons within it are siblings. How incestuous you make this
       assumption depends on the hierarchy you implement

           .data 
             . 
               .
                 %input{ :type => :radio }
       
       Also, note that we are using what's called deferred binding. The radio buttons we 
       click are not present when the document first loads. Hence, click() wouldn't work.
       jQuery 1.7+ has a new, more efficient way of handling this using the new on() method
    */ 

    $('#visible-active-area').on('click', '.data input[type="radio"]', function() { 
      var startPt = $(this).closest('.data') ; 

      if (startPt.length == 0) return ;

      var siblings = startPt.find('input[type="radio"]') ;
      siblings.each( function() { 
        $(this).prop('checked', false) ;
      }) ;

      $(this).prop('checked', true) ;
    }) ;
   

    /* 
      Do the following when a link in the control panel is clicked : 

        1. Clear all panels - #side, #middle, #right and/or #wide - on the page 
        2. Place $(this).attr('side') in the side panel 
        3. Replace old controls in #minor-links with those specified in $(this).attr('load-controls')
    */

    $('#control-panel > #main-links a').click( function() { 
      // Move whatever is in the side and other panels back to where 
      // they came from. Empty any data - that is - anything under .data 
      // (if present) of the to-be-moved element before moving

      $.each(['#side-panel', '#middle-panel', '#right-panel', '#wide-panel'], function(index, panel){
         clearPanel(panel) ;
      }) ;

      // Repopulate the side-panel with whatever is specified in 
      // $(this).attr('side'). All links of this type *must* have 
      // something to show in the side-panel. Otherwise, they are not 
      // worthy of being a .main-link in the #control-panel

      var newStuff = $('#toolbox').find($(this).attr('side')).first() ;

      if (newStuff.length > 0) newStuff.appendTo( $('#side-panel') ) ;

      // Put existing controls - in #minor-links - back where they 
      // came from and put new controls in place - as specified by 
      // $(this).attr('load-controls')

      var existingControls = $('#minor-links').children().first() ;
      var newControls = $( $(this).attr('load-controls') ) ;

      if (existingControls != newControls) { 
        existingControls = existingControls.detach() ;
        existingControls.appendTo('#toolbox') ;
        newControls.appendTo( $('#minor-links') );
      } 

    }) ; 

    /* 
      Do the following when a .minor-link in the control panel is clicked : 
        1. Clear out any #middle & #right panels 
        2. Replace them with any panels specified for $(this) link
    */ 

    $('#control-panel').on('click', '#minor-links a', function() {
      var middle = $( $(this).attr('middle') ) ;
      var currMiddle = $('#middle-panel').children().first() ;

      if (middle != currMiddle && currMiddle.length != 0) {
        clearPanel('#middle-panel') ;
        if (middle.length != 0) middle.appendTo('#middle-panel') ;
      } 

      var right = $( $(this).attr('right') ) ;
      var currRight = $('#right-panel').children().first() ;

      if (right != currRight && currRight.length != 0) {
        clearPanel('#right-panel') ; 
        if (right.length != 0) right.appendTo('#right-panel') ;
      } 
    }) ;

    /* 
      Broadly speaking, do the following when a radio-button in the #side-panel 
      (and nowhere else) is clicked 

        1. Populate sibling panels of the #side-panel with what is specified 
           for #side-panel > first-child ( #summary-table , for example )
        2. Issue any $.get requests tied to the radio-button.
           Affected panels must refresh themselves though
        3. Tweak - as needed - any links in the #control-panel > #minor-links
      
      (1) is done by the following binding
      (2) is done by the next binding in this file 
      (3) might not be possible to do here because it is too context specific. 
          But its been listed here anyways

      This function is kinda like the one for #control-panel > a. But unlike 
      the latter - which changes the whole page - this one's changes are more 
      local - and less "drastic"
    */ 

    $('#side-panel').on('click', 'input[type="radio"]', function() {
      var selection = $(this).closest('.selection') ;

      if (selection.length == 0) return ; 

      var middle = selection.attr('middle') ;
      var right = selection.attr('right') ;
      var wide = selection.attr('wide') ;

      // alert(middle + ', ' + right + ', ' + wide) ;

      if (wide != null) { 
        if (panelXHasY('#wide-panel', wide)) return ;

        clearPanel('#wide-panel') ;
        $('#toolbox').find(wide).first().detach().appendTo('#wide-panel') ;
        // Imp: Hide the other 2 panels so that #wide-panel can take the 2/3 space left 
        //      for it alongside the #side-panel

        $('#wide-panel').removeClass('hidden') ;
        $('#middle-panel, #right-panel').addClass('hidden') ;

      } else {
        // Imp: Hide #wide-panel so that each of #middle-panel & #right-panel 
        //      can get the 1/3 space they require alongside #side-panel

        $('#wide-panel').addClass('hidden') ;
        $('#middle-panel, #right-panel').removeClass('hidden') ;

        if (!panelXHasY('#middle-panel', middle)){
          clearPanel('#middle-panel') ;
          $('#toolbox').find(middle).first().detach().appendTo('#middle-panel') ;
        } 

        if (!panelXHasY('#right-panel', right)) {
          clearPanel('#right-panel') ;
          $('#toolbox').find(right).first().detach().appendTo('#right-panel') ;
        }
      } 
    }) ; // end binding

    $('#visible-active-area').on('click', '#side-panel input[type="radio"]', function() { 
      var url = $(this).attr('url') ;

      if (url != null) $.get(url) ;
    }) ;

    /*
      In all panels - other than the #control-panel - clicking on the radio button 
      should set 'marker' attribute on the panel equal to the 'marker' attribute of the
      radio button. In other words, the panel would know which radio button is currently
      selected. 

      Now, the tricky bit ... The marker should also percolate to any panel to the right
      of this one, that is, from #side -> #middle -> #right OR from #middle -> #right OR 
      from #side -> #wide. In our interface, we assume that panels to the right result from
      some action on a panel to the left. And because we think of these panels as 'siblings',
      lets just say that if the elder sibling gets something, then the younger sibling has 
      to get it too. Its always been true for scolding. Now, its true for marker ;-)
    */ 

    $('.panel:not(id="control-panel")').on('click', 'input[type="radio"]', function() {
      var marker = $(this).attr('marker') ;
      var panel = $(this).closest('.panel:not([class~="horizontal"])') ;
      var panelId = panel.attr('id') ;

      if (marker == null || panel.length == 0) return ; 

      // Set the marker on this panel and then percolate the marker to any 
      // panels on the right

      panel.attr('marker', marker) ;
      panel.siblings('.panel').each( function() { 
         if (panelId == 'middle-panel'){
           if ($(this).attr('id') != 'right-panel') return true ;
         } 
         $(this).attr('marker', marker) ;
      }) ;

    }) ;

    /*
      Trojan fields in forms that have them (see trojan_horse_for helper method in 
      application_helper.rb) need to be filled in with before submission. And usually,
      these trojan fields need to be filled in with the 'marker' attribute set on the 
      parent panel 
    */ 

    $('.panel:not(id="control-panel")').on('submit', 'form', function() {
      var trojanHorse = $(this).find('input[trojan="true"]:first') ;

      if (trojanHorse.length == 0) return ; 

      var panel = $(this).closest('.panel') ;
      var marker = panel.attr('marker') ; 

      if (marker == null) return ; 
      trojanHorse.val(marker) ;
    }) ;

    /*
      All fields in forms that have the class attribute "clear-after-submit" 
      should be cleared on successful AJAX submission. Three things to remember/take 
      care of : 
        1. The attribute is not set on the form but on a containing <div> 
        2. Match the action attribute with the url for successful AJAX call. 
           If they are not the same, then this was not the form submitted and
           hence not the form you want to clear 
        3. If the form is for new record creation, then you will have to issue 
           a respond_with @new_object call in the 'create' action. For reasons I don't 
           fully understand, respond_with @object is caught by ajaxSuccess but 
           not head :ok - even if 'data-remote' is set on the form
    */ 

    $('.clear-after-submit').ajaxSuccess( function(e, xhr, settings) {
       var form = $(this).find('form:first') ;
       if (form.length == 0) return ; 

       var action = form.attr('action') ;
       if (settings.url == action) {
         clearAllFieldsInForm( form ) ; 
       } 
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
    
    $('.action-panel.vertical').each( function() {
       alignVertical( $(this) ) ;
    }) ;

    /*
       Expand 'greedy' elements so that they take all remaining 
       width in their parent

    $('.greedy').each( function() { 
        makeGreedy($(this)) ;
    }) ;

    /*
      Load controls in the #control-panel when a link in the #side-panel is clicked.
      Also, load the empty table - that is, just the headers - in #tables into #data-panel

      However, logic for loading any relevant data into #data-panel would 
      most probably be in the role-specific .js file and would require a separate 
      binding to the same elements listed below

    $('#side-panel').on('click', '#side-panel a.main-link', function() {
      var controls = $(this).attr('load-controls') ;
      var table = $(this).attr('load-table') ;

      if (controls != null && $(controls).length > 0) { 
        replaceControlPanelContentWith(controls) ;
      } 

      if (table != null && $(table).length > 0) {
        replaceDataPanelContentWith(table) ;
        makeGreedy( $(table) ) ; 
        resizeCellsIn( $(table).children('.table').first() ) ;
      }

    }) ; // end 
    */

    /*
      Count the number of columns for all tables. The count is important 
      for dynamic resizing of table columns. Static class attribute values - like 
      wide, regular & narrow - are not sufficient by themselves for telling us 
      what the width should be. If, however, they were to be used to specify relative 
      width ratios, then they might be useful

    $('.table').each( function() { 
      countTableColumns($(this)) ;
      calculateColumnWidths($(this)) ;
    }) ; 
    */ 

    /*
      Updation of the same summary table can be triggered by many distinct events 
      spread across multiple DOM elements. And hence, rather than bind the updation 
      logic part to the triggering DOM element, it makes all the sense to bind 
      the logic to the table itself
    */ 

      /*
    $('.summary-table').ajaxSuccess( function(e, xhr, settings){
      var returnedJSON = $.parseJSON(xhr.responseText) ; 
      // alert(xhr.responseText) ;

      $(this).find('.table > .data').empty() ; // clear existing data first

        There are > 1 summary tables and all of them catch the AJAX success event.
        However, the success event was generated in a context and therefore not all
        tables are supposed to respond to it

        So that is what we do here. We check what the invoking URL was and then 
        which summary table needs to process any returned JSON data. For all other 
        tables, the execution should just fall through

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
      */ 


}) ; // end of file ...


