
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
      For links in #main-panel, lay out the #side-panel and any applicable 
      #middle, #right or #side panels. This functionality can be bound at load-time 
      because the contents of #main-panel are fixed
    */ 
   
    $('#control-panel > #main-links a').click( function() { 
      refreshView( $(this).attr('id') ) ;
    }) ; 

    /*
      Also, load any #minor-links / controls for the clicked #main-link
    */ 

    $('#control-panel > #main-links a').click( function() { 
      var existingControls = $('#minor-links').children().first() ;
      var newControls = $( $(this).attr('load-controls') ) ;

      if (existingControls != newControls) { 
        existingControls = existingControls.detach() ;
        existingControls.appendTo('#toolbox') ;
        newControls.appendTo( $('#minor-links') );
      } 

    }) ; 

    /*
      For #minor-links, refresh the view with any applicable #middle, #right 
      or #wide panels. Note that : 
        1. The #side-panel cannot be touched as it has been put in place by 
           a #main-link 
        2. This binding has to be deferred because the contents of #minor-link 
           are not fluid depending on which #main-link was clicked
    */ 

    $('#control-panel').on('click', '#minor-links a', function() { 
      refreshView( $(this).attr('id') ) ;
    }) ;

    /*
      Clicking a radio button on any panel should initiate an AJAX request 
      for data from the server using any 'url' attribute set on the radio-button
    */ 

    $('.panel:not([id="control-panel"])').on('click', 'input[type="radio"]', function() { 
      var url = $(this).attr('url') ;

      if (url != null) {
        $.get(url) ;
      } 
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
      Update the action attribute of any form inside #side, #middle, #right 
      or #wide panels with the 'marker' attribute on the panel

      For example : If the action attribute is 'schools/update' and the 
      marker attribute on the containing panel is = 2, then change the 
      action attribute to 'schools/update.json?id=2' (yes, we do all submission
      through AJAX) 

      With this scheme, we can write most of the actiob attribute as we know 
      it when we write the view file and be assured that the action attribute 
      would be tweaked - as needed - just before submission
    */ 

    $('.panel:not([id="control-panel"])').on('submit', 'form', function() {
      var panel = $(this).closest('.panel') ; 
      var marker = (panel.length == 0) ? null : panel.attr('marker') ;

      //if (marker == null) return false ; // halt submission?
      var action = $(this).attr('action') ; 

      if (action.match(/\.json\?id=/) != null) { // some .json?id=<> present from before
        action.replace(/id=*/, 'id=' + marker) ;
      } else if (marker != null) { // first time 
        action = action.concat('.json?id=' + marker) ;
      } 
      $(this).attr('action', action) ;
    }) ;


}) ; // end of file ...


