
###
  Define only those bindings here that would apply across all roles.

  These bindings would apply to HTML elements with class, id or other
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
###


jQuery ->

  ###
    Stylize buttons in forms but not in the #control-panel.
    The #control-panel is populated with stuff from #controls and
    styled buttons are too big for that panel
  ###

  $('#toolbox > div:not([class~="top-panel-controls"]) form input[type="submit"]:not([class~="no-style"])').button()

  ###
    Any form for creating or editing a record that needs to be opened as a dialog
    - as opposed to being rendered inline - should have one of new-entity or update-entity
    class attributes. And if these forms need to auto-close on submit, then an
    additional class attribute close-on-submit
  ###

  for poppable in $('.new-entity, .update-entity')
    $(poppable).dialog {
      modal : true,
      autoOpen : false
    }

  ###
    Dialogs that must close themselves when 'submit' - or similar -
    button is clicked. Typically, these are dialogs that have a form in them
  ###

  $('.close-on-submit').ajaxSend ->
    $(this).dialog 'close'

  ###
    Make sortable lists. However, logic for connecting lists that need 
    to connect with each other depends on what the lists are - which 
    in turn depends on who is seeing those lists. Hence, that connecting
    logic should be implemented in role-specific .coffee files
  ###
  $('.sortable').sortable({ dropOnEmpty : true })

  ###
    (Sortables) : When an element is moved from an .selected to an 
    .deselected, then disable any visible active elements (radios, checkboxes etc) 
    within it. Conversely, when an element is moved in the other 
    direction (.out -> .in), enable any radio buttons 
  ###

  $('.sortable').on 'sortreceive', (event, ui) ->
    ###
      ui.item is the item that was dragged and placed within another .sortable
    ###
    parent = ui.item.closest '.sortable'
    return if parent.get(0) isnt $(this).get(0) # read up on jQuery object comparison
    disable = if $(this).hasClass 'selected' then false else true

    for element in ui.item.children()
      continue if $(element).hasClass 'hidden'
      $(element).prop 'disabled', disable
      $(element).prop 'checked', false
    

  ###
    In our forms, if a checkbox is checked, then it should submit 'true',
    else 'false'. Note, that this is just how we interpret checkboxes.
    The value really does not have to be only true/false. It could be
    anything - my name, your name etc. etc.
  ###

  $('form').on 'click', 'input[type="checkbox"]', ->
    $(this).val $(this).prop 'checked'

  ###
     Clicking on one radio-button should unclick all other 'sibling' radio buttons.
     This is what the code below does. However, defining 'siblings' is tricky
     given the infinite hierarchies that can be implemented. No code can address
     the question completly for all situations. And so, this code makes the following
     simplifying assumptions (shown below) - 1. there is a <div class="data"> element
     AND 2. all radio-buttons within it are siblings. How incestuous you make this
     assumption depends on the hierarchy you implement

         .purgeable
           .
             .
               %input{ :type => :radio }

     Also, note that we are using what's called deferred binding. The radio buttons we
     click are not present when the document first loads. Hence, click() wouldn't work.
     jQuery 1.7+ has a new, more efficient way of handling this using the new on() method
  ###

  for type in ['side', 'middle', 'right', 'wide']
    panel = $("##{type}-panel")
    panel.on 'click', '.swiss-knife > input[type="radio"]', ->
      parent = $(this).closest '.swiss-knife'
      if parent.length isnt 0
        for cousin in parent.siblings('.swiss-knife').find('input[type="radio"]')
          $(cousin).prop 'checked', false

  ###
    For any link in the #control-panel, refresh the view with any applicable
    #side, #middle, #right or #wide panels. Also, set the selected=true attribute
    on the link just clicked whilst removing it from all other siblings. 
    Note however that : 
      1. A minor link cannot remove the #side-panel as it has been put in place by
         a #main-link
  ###

  $('#control-panel').on 'click', '#main-links a, #minor-links a', ->
    coreUtil.interface.refreshView $(this)

    ###
      Set 'selected=true' on $(this) whilst setting it to false on all other siblings/cousins
    ###
    parent = $(this).closest 'li'
    if parent.length isnt 0
      uncles = parent.siblings 'li'
      for uncle in uncles
        for cousin in $(uncle).children 'a'
          $(cousin).attr 'selected', false
    $(this).attr 'selected', true
    if $(this).hasClass 'main-link'
      for minor in $('#minor-links').find 'a'
        $(minor).attr 'selected', false
    return true

  ###
    Also, load any #minor-links / controls for the clicked #main-link
  ###

  $('#control-panel > #main-links a').click ->
    currControls = $('#minor-links').children().first()
    neededControls = $($(this).attr 'load-controls')

    if currControls isnt neededControls
      currControls = currControls.detach()
      currControls.appendTo '#toolbox'
      neededControls.appendTo $('#minor-links')

  ###
    In all panels - other than the #control-panel - clicking on the radio button
    should set 'marker' attribute on the panel equal to the 'marker' attribute of the
    radio button. In other words, the panel would know which radio button is currently
    selected.
  ###

  $('.panel:not([id="control-panel"])').on 'click', 'input[type="radio"]', ->
    marker = $(this).attr 'marker'
    unless marker is null
      panel = $(this).closest '.panel'
      if panel.length isnt 0
        panelId = panel.attr 'id'
        panel.attr 'marker', marker
    return true

  ###
    All fields in forms that have the class attribute "clear-after-submit"
    should be cleared on successful AJAX submission. Three things to remember/take
    care of :
      1. The attribute is not set on the form but on a containing/parent <div>
      2. Match the action attribute with the url for successful AJAX call.
         If they are not the same, then this was not the form submitted and
         hence not the form you want to clear
      3. If the form is for new record creation, then you will have to issue
         a respond_with @new_object call in the 'create' action. For reasons I don't
         fully understand, respond_with @object is caught by ajaxSuccess but
         not head :ok - even if 'data-remote' is set on the form
  ###

  $('.clear-after-submit').ajaxSuccess (e,xhr,settings) ->
    form = $(this).find 'form:first'
    return if form.length is 0

    action = form.attr 'action'
    coreUtil.forms.clear form if action is settings.url

  ###
    If a <form> has or requires multiple submit buttons, then house each 
    submit button within a .submit-buttons
    
    Now, in order to differentiate which submit was clicked, set an 
    attribute on the clicked button whilst removing it from all its 
    siblings within .submit-buttons
  ###
  $('.submit-buttons input[type="submit"]').click ->
    $(this).attr 'clicked', true
    for others in $(this).siblings('input[type="submit"]')
      $(others).attr 'clicked', false

  ###
    Submit buttons of forms in .panels can be double-up to provide status
    message on the on-going process. Something like, "Working" when they are
    clicked and "Done!" or "Oops!!" depending on Ajax success or failure
  ###

  $('.panel:not([id="control-panel"])').on 'submit', '.clear-after-submit form:first', ->
    button = $(this).find 'input[type="submit"]:first'
    if button?
      button.val 'Working'
  .ajaxSuccess (e,xhr,settings) ->
    form = $(this).find '.clear-after-submit form:first'
    if form?
      if settings.url is form.attr('action')
        button = $(this).find 'input[type="submit"]:first'
        if button?
          button.val 'Done'
  .ajaxError (e,xhr,settings) ->
    form = $(this).find '.clear-after-submit form:first'
    if form?
      if settings.url is form.attr('action')
        button = $(this).find 'input[type="submit"]:first'
        if button?
          button.val('Oops !')

  ###
    If a radio button within the macro-selected-list is clicked, then 
    make the corresponding micro-topics in #micro-selected-list visible.
    But do this only if #micro-selected-list is in view - that is - 
    not in the #toolbox. And leave any other context specific customization
    to the context specific JS file
  ###

  $('#macro-selected-list').on 'click', 'input[type="radio"]', ->
    return if $('#toolbox').children('#micro-selected-list').length isnt 0

    marker = $(this).attr 'marker'
    for macro in $('#micro-selected-list').children("div[marker]")
      id = $(macro).attr 'marker'
      hide = if id is marker then false else true
      if hide then $(macro).addClass('hidden') else $(macro).removeClass('hidden')
    return true

  ###
    If a <form> has a button of class 'check-all', then on clicking it 
    the state of all visible checkboxes within the <form> should toggle - that is -
    go from unchecked to checked or checked to unchecked
  ###

  $('form').on 'click', 'input[type="button"][class~="check-all"]', ->
    form = $(this).closest 'form'
    return if form.length is 0
    check = if $(this).attr('all-checked') is 'yes'then false else true # toggle
    if $(this).attr('all-checked') is 'yes'
      next = false
      $(this).attr 'all-checked', 'no'
      $(this).val 'select all'
    else
      next = true
      $(this).attr 'all-checked', 'yes'
      $(this).val 'unselect all'

    coreUtil.forms.checkAllIn form, next
    return true
    
