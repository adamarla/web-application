
###
  Define only those bindings here that would apply across all roles.

  These bindings would apply to HTML elements with class, id or other
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
###


jQuery ->
  ### Click #schools-link on load ###

  ###
    Stylize buttons in forms but not in the #control-panel.
    The #control-panel is populated with stuff from #controls and
    styled buttons are too big for that panel
  ###

  $('#toolbox > div:not([class~="top-panel-controls"]) form input[type="submit"]').button()

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
    In our forms, if a checkbox is checked, then it should submit 'true',
    else 'false'. Note, that this is just how we interpret checkboxes.
    The value really does not have to be only true/false. It could be
    anything - my name, your name etc. etc.
  ###

  $('form, .mega-form').on 'click', 'input[type="checkbox"]', ->
    $(this).val $(this).prop 'checked'

  ###
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
  ###

  for type in ['side', 'middle', 'right', 'wide']
    panel = $('#' + type + '-panel')
    panel.on 'click', '.data input[type="radio"]', ->
      startPt = $(this).closest '.data'
      if startPt.length isnt 0
        for sibling in startPt.find 'input[type="radio"]'
          $(sibling).prop 'checked', (if sibling is this then true else false)

  ###
    For any link in the #control-panel, refresh the view with any applicable
    #side, #middle, #right or #wide panels. Note that :
      1. A minor link cannot remove the #side-panel as it has been put in place by
         a #main-link
      2. It can, however, update url's for radio-buttons in the #side-panel
  ###

  $('#control-panel').on 'click', '#main-links a, #minor-links a', ->
    refreshView $(this).attr 'id'
    return true if $(this).hasClass 'main-link'

    ###
      Don't update radio-urls on main-link click. Why ? Because there are no
      radio-buttons to update ! Clicks on main-links invariably involve an AJAX
      request for data. That data takes time to come and then some more time
      before it can be rendered into a list with radio-buttons. One must wait
      therefore for that process to finish. As this is not the case with
      #minor-links, those can be processed now
    ###
    resetRadioUrlsAsPer $(this)

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
    For both #main and #minor links, a click should result in some
    persistent visual feedback suggesting which link was clicked
  ###

  $('#control-panel').on 'click', '.main-link, .minor-link', ->
    uncles = $(this).closest('li').siblings()

    for uncle in uncles
      for cousin in $(uncle).children('a:first')
        $(cousin).css 'border', 'none'

    $(this).css 'border-bottom', '2px solid #6ca7ab'
    return true

  ###
    Clicking a radio button on any panel should initiate an AJAX request
    for data from the server using any 'url' attribute set on the radio-button

    What that url is - however - is not defined here. That is a property of
    the link and moreover can only be set after the radio-button has been
    put in place - perhaps after an AJAX request

    Moreover, it might be that a radio button has to issue multiple AJAX calls
    on one click. In that case, the 'url' by the link on the radio is of the
    form 'a|b|c...|...', where a,b,c ... are the urls to call
  ###

  $('.panel:not([id="control-panel"])').on 'click', 'input[type="radio"]', ->
    url = $(this).attr 'url'
    if url?
      call = url.split '|'
      for link in call
        $.get link

  ###
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
  ###

  $('.panel:not([id="control-panel"])').on 'click', 'input[type="radio"]', ->
    marker = $(this).attr 'marker'
    unless marker is null
      panel = $(this).closest '.panel'
      if panel.length isnt 0
        panelId = panel.attr 'id'
        panel.attr 'marker', marker

        if panelId is 'side-panel' or panelId is 'middle-panel'
          for sibling in $(panel).siblings '.panel'
            continue if panelId is 'middle-panel' and $(sibling).attr('id') isnt 'right-panel'
            $(sibling).attr 'marker', marker


  ###
    Trojan fields in forms that have them (see trojan_horse_for helper method in
    application_helper.rb) need to be filled in with before submission. And usually,
    these trojan fields need to be filled in with the 'marker' attribute set on the
    parent panel
  ###

  $('.panel:not([id="control-panel"])').on 'submit', 'form', ->
    trojanHorse = $(this).find 'input[trojan="true"]:first'
    return if trojanHorse.length is 0

    panel = $(this).closest '.panel'
    marker = if panel.length isnt 0 then panel.attr 'marker' else null
    trojanHorse.val marker if marker isnt null

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
    clearAllFieldsInForm form if action is settings.url

  ###
    Update the action attribute of any form inside #side, #middle, #right
    or #wide panels with the 'marker' attribute on the panel

    For example : If the action attribute is 'schools/update' and the
    marker attribute on the containing panel is = 2, then change the
    action attribute to 'schools/update.json?id=2' (yes, we do all submission
    through AJAX)

    With this scheme, we can write most of the actiob attribute as we know
    it when we write the view file and be assured that the action attribute
    would be tweaked - as needed - just before submission
  ###

  $('.panel:not([id="control-panel"])').on 'submit', 'form', ->
    panel = $(this).closest '.panel'
    marker = if panel.length isnt 0 then panel.attr 'marker' else null
    return if marker is null

    action = $(this).attr 'action'
    lastBit = action.match /json\?id=\d+/
    if lastBit isnt null # some json?id= from before
      action = action.replace lastBit, ('json?id=' + marker)
    else
      action = action.concat('.json?id=' + marker)

    $(this).attr 'action', action
    return true

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

  $('.sortable').sortable()

