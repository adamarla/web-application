
window.gutenberg = {
  serverOptions : {
    local : "http://localhost:8080",
    remote : "http://109.74.201.62:8080"
  },
  server : null
}

###
  Define only those bindings here that would apply across all roles.

  These bindings would apply to HTML elements with class, id or other
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
###


jQuery ->
  $(document).keydown (event) ->
    return if $('#wide-panel').hasClass 'hidden'

    images = $('#wide-panel').children().first()
    return if images.length is 0

    if images.hasClass 'ppy-placeholder'
      preview.scrollImg(images, event) unless preview.blockKeyPress
    return true

  # If on the trial signup page, then render the country <select> as an
  # auto-complete widget using the country-select plugin

  countrySelect = $('#trial_country')
  if countrySelect.length isnt 0
    countrySelect.selectToAutocomplete()
    countrySelect.find('+ input').attr 'placeholder', 'country'

  ###
    Store the value attribute of each and every input[type='submit'] button as a 
    separate attribute called 'reset-to'. We will reset button text to this value 
    2 seconds after the AJAX response is received 
  ###
  for m in $("input[type='submit']")
    v = $(m).val()
    continue if not v?
    $(m).attr 'reset-to', v

  ###
    This next call is unassuming but rather important. We initialize 
    variables within the JS based on the results the server being accessed returns
  ###
  pinghandler = (response) ->
    if response.deployment is 'production'
      gutenberg.server = gutenberg.serverOptions.remote
    else
      gutenberg.server = gutenberg.serverOptions.local
    
  pingargs =
  	url: '/ping'
  	success: pinghandler
  	async: false
  	
  $.ajax pingargs

  ###
    Now that we know what type of server we are interacting with, we can tweak 
    the scanloader download button to work with that server 
  ###
  
  scanbotDownload = $('#scanbot-getting-it a:first')

  ###
  if navigator.platform.indexOf("Win") == -1 
    scanbotDownload.attr 'href', "#{gutenberg.server}/scanLoader/scanLoader.jnlp"
  else
    if navigator.userAgent.indexOf("MSIE") == -1
      scanbotDownload.attr 'href', "#{gutenberg.server}/winbot/app.publish/setup.exe"
    else
      scanbotDownload.attr 'href', "#{gutenberg.server}/winbot/app.publish/winbot.application"

  ###
  scanbotDownload.button()

  ###
    Load the first video when #videos-link is clicked. Let users have something to play
  ###
  $('#videos-link').click (event) ->
    $('#video-titles > a.howto-video:first').click()
    return true

  ###
    Any form for creating or editing a record that needs to be opened as a dialog
    - as opposed to being rendered inline - should have one of new-entity or update-entity
    class attributes. And if these forms need to auto-close on submit, then an
    additional class attribute close-on-submit
  ###

  for poppable in $('.new-entity, .update-entity')
    $(poppable).dialog {
      modal : true,
      autoOpen : false,
      open: (event, ui) ->
        preview.blockKeyPress = true
        canvas.blockKeyPress = true
        return true
      close: (event, ui) ->
        preview.blockKeyPress = false
        canvas.blockKeyPress = false
        return true
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
  ###

  $('#control-panel').on 'click', '#main-links a, #minor-links a', ->
    coreUtil.interface.refreshView $(this)
    selection.initialize() # any prior selections should be cleared 

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
        panel.attr 'marker', marker
    return true

  $('#grade-controls').on 'click', 'input[type="radio"]', ->
    for label in $(this).siblings('label')
      $(label).removeClass 'clicked'

    label = $(this).next('label')
    label.addClass 'clicked' unless label.length is 0

    # There is one %input[type=>number] to store the marker of 
    # the clicked radio-button. Update it
    number = $(this).siblings('input[type="number"]').first()
    number.val $(this).attr('marker') unless number.length is 0
    return true

  ###
    Clear forms on successful submission
      1. Match the action attribute with the url for successful AJAX call.
         If they are not the same, then this was not the form submitted and
         hence not the form you want to clear
  ###

  $('form').ajaxSuccess (e,xhr,settings) ->
    dontClear = ['topic-selection-list', 'calibrations']
    action = $(this).attr 'action'

    if action is settings.url
      parent = $(this).parent().attr 'id'
      return if not parent? or parent in dontClear else coreUtil.forms.clear $(this)
    return true

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

  $('.panel:not([id="control-panel"])').on 'submit', 'form', ->
    button = $(this).find 'input[type="submit"]:first'
    if button?
      button.val 'Working'
  .ajaxSuccess (e,xhr,settings) ->
    forms = $(this).find 'form'
    for form in forms
      if settings.url is $(form).attr('action')
        e.stopPropagation()
        button = $(form).find 'input[type="submit"]:first'
        if button?
          json = $.parseJSON xhr.responseText
          if json.status? then button.val(json.status) else button.val("Done")

          reset = button.attr 'reset-to'
          if reset?
            window.setTimeout ->
              button.val reset
            , 1300
            
    return true
  .ajaxError (e,xhr,settings) ->
    forms = $(this).find 'form'
    for form in forms
      if settings.url is $(form).attr('action')
        e.stopPropagation()
        button = $(form).find 'input[type="submit"]:first'
        if button?
          json = $.parseJSON xhr.responseText
          if json.status? then button.val(json.status) else button.val("Oops!")
    return true

  ###
    If a radio button within the vertical-selected-list is clicked, then 
    make the corresponding topics in #topic-selected-list visible.
    But do this only if #topic-selected-list is in view - that is - 
    not in the #toolbox. And leave any other context specific customization
    to the context specific JS file
  ###

  $('#vertical-selected-list').on 'click', 'input[type="radio"]', ->
    return if $('#toolbox').children('#topic-selected-list').length isnt 0

    marker = $(this).attr 'marker'
    for vertical in $('#topic-selected-list').children("div[marker]")
      id = $(vertical).attr 'marker'
      hide = if id is marker then false else true
      if hide then $(vertical).addClass('hidden') else $(vertical).removeClass('hidden')
    return true

  ###
    If a <form> has a button of class 'check-all', then on clicking it 
    the state of all visible checkboxes within the <form> should toggle - that is -
    go from unchecked to checked or checked to unchecked
  ###

  $('form').on 'click', 'input.check-all[type]', ->
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

  ###
    Initialize all flipcharts 
  ###

  for chart in $('.flipchart')
    flipchart.initialize $(chart)

  ###
    In Admin & Teacher consoles, allotments for various yardsticks can be 
    changed using a slider. These sliders - when slid - update a ticker
    Define this functionality here
  ###
  
  containingTab = (obj) ->
    # Call only with the slider element in #yardsticks-summary
    panel = obj.closest('.panel').attr 'id'
    anchor = $('#yardsticks-summary').find("ul > li > a[href=##{panel}]").eq(0)
    return anchor



  $('#toolbox').find('.grade-btns-non-mcq:first').buttonset()
  $('#toolbox').find('.grade-btns-mcq:first').buttonset()

  ###
    If #quiz_name gets focus when building a Quiz, then don't interpret 
    keys 'B' and 'N' as one normally would during previews. Resume 
    interpretation as usual when #quiz_name loses focus
  ###

  $('#quiz_name').focus () ->
    preview.blockKeyPress = true
  .blur () ->
    preview.blockKeyPress = false

  ###
    Hide student marks and reveal them for just 1 second if ticker is clicked.
    The code below looks the way it does because setTimeout in IE does not accept
    arguments

    Ref: http://www.lejnieks.com/2008/passing-arguments-to-javascripts-settimeout-method-using-closures/
  ###

  ticker = null
  toggleOnClick = () ->
    text = ticker.text()
    switchTo = ticker.attr 'toggle'
    ticker.text switchTo
    ticker.attr 'toggle', text
    return true

  $('#overview').on 'click', '.swiss-knife > .ticker', (event) ->
    toggable = if $(this).attr('toggle')? then true else false
    if toggable
      ticker = $(this)
    else
      ticker = null
      return false

    toggleOnClick()
    window.setTimeout toggleOnClick, 1000
    return true

  ###
    If either a student or a teacher clicks on a graded question, then 
    load its calibration breakup 
  ###

  $('#report-cards-summary > #preview, #my-grades').on 'click', '.swiss-knife', (event) ->
    event.stopPropagation()
    id = $(this).attr 'marker'
    $(m).removeClass 'selected' for m in $(this).siblings()
    $(this).addClass 'selected'
    $.get "comments/for?id=#{id}"
    return true

  ###
    Store the just picked colour for annotation in canvas.ctx object
  ###
  $('#colour-picker > div[coloured]').click (event) ->
    event.stopPropagation()
    colour = $(this).children('[colour]').eq(0).attr 'colour'
    canvas.colour.last = canvas.colour[colour]
    canvas.mode = colour
    $(m).removeClass 'selected' for m in $(this).siblings()
    $(this).addClass 'selected'
    return true

