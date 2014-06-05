
getMarker = (obj) ->
  marker = $(obj).attr 'marker'
  return marker if marker?
  if $(obj).is 'li'
    a = $(obj).children('a')[0]
    return null unless a?
    return getMarker(a)
  return null

window.sieve = {
  through : (obj) ->
    # Given a hierarchy like ... <div [filter]> .... <obj>, this method would 
    # unhide .lines with class=filter within <div [filter]> 
    root = obj.closest('[filter]')[0]
    return false unless root?
    klass = $(root).attr 'filter'
    lines = $(root).find '.line'
    $(m).removeClass('hide') for m in lines

    switch klass
      when 'none' then break
      when 'checkbox_checked'
        for m in lines
          checked = $(m).find("input[type='checkbox']").eq(0).prop 'checked'
          $(m).addClass('hide') unless checked
      else
        $(m).addClass('hide') for m in lines.filter(":not([class~=#{klass}])")

    return true
}

window.gutenberg = {
  serverOptions : {
    local : "http://localhost:8080",
    remote : "http://109.74.201.62:8080"
  },
  server : null
}

window.rails = {
  serverOptions : {
    local : "http://localhost:3000",
    remote : "http://www.gradians.com"
  }
  server : null
}

###
  Define only those bindings here that would apply across all roles.

  These bindings would apply to HTML elements with class, id or other
  attributes that can occur across roles in the role-specific HTML.

  HTML elements that are specific to a particular role should be bound
  the role-specific .js file
###

window.trigger = {

  click : (link, event = null) ->
    event.stopImmediatePropagation() if event?
    noGo = $(link).hasClass('disabled') or $(link).hasClass('carousel-control')
    return true if noGo 

    if $(link).parent().hasClass 'dropdown-submenu'
      isDefault = if link.getAttribute('data-default')? then true else false
      return false unless isDefault

    type = link.getAttribute 'data-toggle'
    isTab = type is 'tab'
    isModal = type is 'modal'
    # event.stopImmediatePropagation() if event? and (isTab or isModal)

    # (YAML) Hide / unhide panels as needed
    noTouch = link.getAttribute('data-no-touch')
    noTouch = if noTouch? then (noTouch is 'true') else false

    unless noTouch
      for j in ['left', 'right', 'middle', 'wide']
        show = link.getAttribute("data-show-#{j}")
        if typeof show is 'string'
          continue if show is 'as-is'

        panel = $("##{j}")
        if not show?
          continue if isTab
          panel.addClass 'hide'
          continue
        panel.removeClass 'hide'
        karo.unhide(show, panel) unless show is 'no-remove'

    return true if isTab
    # process tabs here only insofar as hiding/unhiding is concerned

    # If <a data-show-modal>, then do that 
    showModal = link.getAttribute 'data-show-modal'
    $("##{showModal}").modal() if showModal?

    # If there be a tab that needs to be auto-clicked, then do that too
    # tab = link.dataset.autoclickTab
    tab = link.getAttribute('data-autoclick-tab')
    karo.tab.enable tab if tab?

    # If <a data-show-video> then
    showVideo = link.getAttribute 'data-show-video'

    if showVideo is 'true'
      obj = $(link).closest('.video')[0]
      video.play obj if obj?

    # If <a> is within a dropdown-menu, then close the dropdown menu
    menu.close $(link)

    # (YAML) Issue any AJAX requests
    ajax = link.getAttribute('data-ajax')
    if ajax isnt 'disabled'
      ajax = karo.url.elaborate link
      karo.ajaxCall ajax if ajax?

    # launch any help tied to this link
    help = link.getAttribute('data-show-help')
    if help?
      autoclick = link.getAttribute('data-autoclick')
      trigger.click $("##{autoclick}")[0] if autoclick?
      tutorial.active = true if $(link).hasClass('help')
      tutorial.start help

    return true
}

jQuery ->


  ###
    A spinner to show that AJAX request is in process. The spinner is shown only 
    in the control panel 
  ###

  $('body').bind 'ajaxSend', () ->
    spinner.start()
  .bind 'ajaxStop', () ->
    spinner.stop()
  .bind 'ajaxError', () ->
    spinner.stop()

  # Initialize tutorials
  tutorial.initialize()

  ###
    This next call is unassuming but rather important. We initialize 
    variables within the JS based on the results the server being accessed returns
  ###

  onPing = (response) ->
    # Unhide the console 
    $('body > .container-fluid').removeClass('hidden')

    # Start monitoring progress of any pending Delayed::Jobs
    monitor.add response, true

    # Set server 
    if response.deployment is 'production'
      gutenberg.server = gutenberg.serverOptions.remote
      rails.server = rails.serverOptions.remote
    else
      gutenberg.server = gutenberg.serverOptions.local
      rails.server = rails.serverOptions.local

    if response.new is true
      switch response.who 
        when 'Teacher'
          break 
        when 'Student'
          $('#m-new-login').modal('show') 
        when 'Examiner'
          notifier.show 'n-sandbox'

    # if logged in user is a teacher, then update her demo info (which demos done, which remain)
    # if response.who is 'Teacher'
    #  demo.initialize(response.demos)
    #  $('#m-demo-intro').modal('show') if response.new is true
    return true
    
  pingArgs =
  	url: '/ping'
  	success: onPing
  	async: false

  $.ajax pingArgs

  $('#how-it-works').carousel({
    interval : 10000
  })


  ###
    Add and initialize all stopwatches 
  ###
  for m in $('.stopwatch')
    stopWatch.add m
  stopWatch.initialize()

  ###
    HUGELY IMPORTANT: Detect whether or not client browser supports the HTML5 
    features we require. If not, then let the user know

    We use an external plugin called Modernizr for doing the checks. Rather 
    than get the browser name and version - if can be overwritten - its better 
    to detect the features the browser supports
  ###
  if Modernizr?
    allGood = Modernizr.canvas and Modernizr.canvastext and Modernizr.rgba and Modernizr.svg
    # allGood = false
    unless allGood 
      signinForm = $('#signin-form')
      signinBtn = signinForm.find('button').eq(0)

      signinBtn.addClass 'disabled'
      signinBtn.text 'Old Browser!'
      signinForm.attr 'onsubmit', 'return false;'
      notifier.show 'n-old-browser' 


  #####################################################################
  ## Forms within dropdown menus  
  #####################################################################
  $('li.dropdown').on 'click', 'form button', (event) ->
    btn = $(this)
    submit = if btn.hasClass('dismiss') then false else true
    unless submit
      event.stopImmediatePropagation()
      $(this).closest('li.dropdown').removeClass 'active' # call before removing form from OM
      menu.close btn, true
    return submit

  ###
  $('li.dropdown').on 'submit', 'ul.dropdown-menu form', (event) ->
    $(this).closest('li.dropdown').removeClass 'active'
    menu.close $(event.target), true
    return true

  #####################################################################
  ## Do nothing if a.brand is clicked 
  #####################################################################

  $('a.brand').click (event) ->
    event.stopImmediatePropagation()
    return false

  #####################################################################
  ## [control-panel]: Highlight the dropdown-toggle if 
  ## dropdown-menu > li > a  is clicked
  #####################################################################


  #####################################################################
  # Behaviour of button-groups that are within forms
  #####################################################################

  $('form').on 'click', '.btn-group button', (event) ->
    buttonGroup.click $(this)
    return false # because we don't want to trigger form submission

  $('html').click (event) -> # handles cases other than those handled by bindings below 
    for m in $('.g-panel')
      for p in $(m).find '.dropdown-menu'
        menu.close $(p)
    return true

  ###############################################
  # When a tab is clicked and shown
  ###############################################
  $(".g-panel").on 'click', "a[data-toggle='modal']", (event) ->
    return trigger.click this

  $(".g-panel").on 'click', "a[data-toggle='tab']", (event) ->
    li = $(this).parent()
    name = $(this).attr 'id'

    prev = this.getAttribute('data-prev')
    if li.hasClass 'disabled'
      event.stopImmediatePropagation()
      return false
    else if prev?
      m = $("##{prev}").parent() # the <li> - not the <a>
      if not m.attr('marker')? # no selection made in data-prev
        event.stopImmediatePropagation()
        return false
    trigger.click this
    return true

  $(".g-panel").on 'shown', "a[data-toggle='tab']", (event) ->
    event.stopPropagation()
    name = $(this).attr 'id'

    # Empty the last-enabled tab's contents - if needed
    prevTab = event.relatedTarget
    unless $(prevTab).length is 0
      unless karo.checkWhether prevTab, 'nopurge-on-inactive'
        karo.empty $(prevTab).attr('href')

    # Empty the currently-enabled tab's contents - if needed
    empty = not karo.checkWhether(this, 'nopurge-on-show')
    if empty
      karo.empty $(this).attr('href')

    ###
      Do the next two for only * horizontal * tabs - not .tabs-left or .tabs-right
        1. Ensure that atmost 3 tabs are shown - including the just clicked one
        2. disable all subsequent tabs 

      Side tabs are for special use-cases and therefore one can't make a 
      blanket call on their behaviour. 
    ###
    ul = $(this).parent().parent() # => ul.nav-tabs
    tabbable = ul.parent()
    isSideTab = tabbable.hasClass('tabs-left') || tabbable.hasClass('tabs-right')

    unless isSideTab 
      li = $(this).parent()
      li.removeClass 'hide'

      for m in li.nextAll('li')
        $(m).addClass 'disabled' unless karo.checkWhether(m, 'always-on')
        tab = $(m).children('a')[0]
        unless karo.checkWhether tab, 'nopurge-on-disable'
          karo.empty $(tab).attr('href')

    # Issue AJAX request * after * taking care of any :prev or :id in data-url
    # Enable / disable paginator accordingly 

    ajax = karo.url.elaborate this
    panel = $(this).closest('.g-panel')[0]
    pgn = $(panel).children('.paginator').eq(0)

    if ajax?
      proceed = true
      if karo.checkWhether this, 'nopurge-on-show'
        z = $($(this).attr('href'))
        proceed = z.hasClass('static') || (z.children().filter(":not([class~='purge-skip'])").length is 0)
      paginator.initialize(pgn, ajax, this) unless isSideTab
      karo.ajaxCall(ajax, this, isSideTab) if proceed
    else
      # launch any help tied to this link. Do this ONLY for tabs that do NOT 
      # result in an ajax call. For tabs that do, tutorials are launched AFTER
      # AJAX response has been received

      # help = this.dataset.launch
      help = this.getAttribute('data-show-help')
      tutorial.start(help) if help?

    # Set base-ajax url on containing panel
    unless ul.hasClass 'lock'
      # panelUrl = this.dataset.panelUrl
      panelUrl = this.getAttribute('data-url-panel')

      #panel.dataset.url = if panelUrl? then panelUrl else null
      if panelUrl?
        panel.setAttribute('data-url', panelUrl)
      else
        panel.setAttribute('data-url', null)

    # Auto-click any autoclick links - but not tabs 
    # autoLink = this.dataset.autoclickLink
    autoLink = this.getAttribute('data-autoclick-link')
    $("##{autoLink}").click() if autoLink?

    ###
      If corresponding tab-pane has statically rendered .tabs-left, 
      then autoclick the first tab
    ###
    pane = $($(this).attr('href'))
    resetChildTabs = this.getAttribute('data-childtabs-reset') is 'true'

    for m in pane.find('.tabs-left')
      tabs = $(m).find('ul > li')
      if resetChildTabs
        $(j).removeClass('active') for j in tabs
      firstTab = tabs.eq(0).children('a').eq(0)
      firstTab.click()

    ###
      Run any filters in the parent hierarchy
    ###
    sieve.through $(this)
    return true

  ###############################################
  # When an item in a dropdown menu is selected 
  ###############################################

  $(".g-panel:not([id='control-panel']), #toolbox").on 'click', '.dropdown-menu > li > a', (event) ->
    return trigger.click this, event

  $('#control-panel ul.nav').on 'click', 'li > a', (event) ->
    # li > a.dropdown-toggle will be processed by another event handler in this file
    menu = $(this).closest("ul[role='menu']")[0]
    toggle = if menu? then $(menu).prev() else $(this)

    # Mark this toggle as selected and all other <a.dropdown-toggle> or even just <a> as unselected
    toggle.addClass('selected')
    parent = toggle.parent() # must be a <li>
    for m in parent.siblings('li')
      $(m).children("a").removeClass 'selected'

    # now process the click as normal
    return trigger.click this, event

  ###############################################
  # When an <a> in control-panel is clicked. The 
  # <a> is NOT within a dropdown though
  ###############################################

  $('#control-panel, .hero-unit').on 'click', 'a', (event) ->
    return false if $(this).closest('ul').eq(0).hasClass 'dropdown-menu'
    return trigger.click this, event

  ###############################################
  # When the caret to open a contextual menu is clicked 
  ###############################################

  $('.dropdown-toggle').click (event) ->
    event.stopPropagation()
    return false if $(this).hasClass 'disabled'

    # close all sibling menus. Menus within .line handled by catch all 
    parent = $(this).parent()
    if parent.is 'li' # => within control panel
      for m in parent.siblings('li')
        menu.close $(m)
    menu.show this
    return true

  ###############################################
  # When a paginator link is clicked 
  ###############################################

  $('.paginator a').click (event) ->
    event.stopPropagation()
    li = $(this).parent()
    return false if li.hasClass 'disabled'
    for m in li.siblings 'li'
      $(m).removeClass 'active'
    li.addClass 'active'
    karo.ajaxCall $(this).attr 'href'
    return false # already issued AJAX GET request. No need for further processing

  ###############################################
  # When a single line is clicked  
  ###############################################

  $('.content, .tab-pane, .column, .modal').on 'click', '.line', (event) ->
    ###
       Yes, this method does not allow a contextual menu to open if the 
       .line hasnt been selected first 
    ###
    return false if $(this).hasClass 'disabled'

    clickedObj = $(event.target)
    m = null
    hasButton = $(this).children('.btn').length > 0
    # alert clickedObj.attr('class')

    if clickedObj.hasClass('dropdown')
      m = clickedObj
    else if clickedObj.hasClass 'dropdown-toggle'
      m = clickedObj.parent()
    else if clickedObj.hasClass('btn') or clickedObj.is('i') 
      ### 
        Above solves two issues
          61: event.target different on Chrome
          65: limited nesting within <button> allowed by IE
      ###
      clickedObj = if clickedObj.is('i') then clickedObj.parent() else clickedObj
      checkBox = clickedObj.children("input[type='checkbox']")[0] 

      if clickedObj.hasClass('active')
        clickedObj.removeClass 'active'
        $(checkBox).prop('checked', false) if checkBox?
      else
        clickedObj.addClass 'active'
        $(checkBox).prop('checked', true) if checkBox?

      return clickedObj.hasClass 'video'
    else if clickedObj.is 'li > a' # menu-item in contextual menu
      event.stopImmediatePropagation()
      return trigger.click event.target 

    if m? # => if clicked to see dropdown menu
      event.stopImmediatePropagation()
      if m.parent().hasClass('selected') then menu.show m.find('.dropdown-toggle')[0] else return false
    else # elsewhere on the line => select / de-select
      event.stopPropagation() 

      parent = $(this).parent()
      multiOk = if hasButton then false else parent.hasClass('multi-select') # parent = .content / .tab-pane / form
      reissueAjax = parent.hasClass 'reissue-ajax'
      activeTab = $(this).closest('.tab-content').prev().children('li.active')[0]
      
      badge = $(this).find('.badge').eq(0)
      otherLines = $(this).siblings('.line')
      isClicked = if reissueAjax then false else $(this).hasClass('selected') # issues 55 and 112

      if isClicked
        if multiOk
          $(this).removeClass 'selected'
          badge.removeClass 'badge-warning'
          $(this).find("input[type='checkbox']").eq(0).prop('checked', false) unless hasButton
      else
        $(this).addClass('selected')
        badge.addClass 'badge-warning'
        $(this).find("input[type='checkbox']").eq(0).prop('checked', true) unless hasButton

        unless multiOk
          # 1. Remove selected from siblings if not multi-select
          for k in otherLines
            $(k).removeClass 'selected'
            $(k).find('.badge').eq(0).removeClass 'badge-warning'
            $(k).find("input[type='checkbox']").eq(0).prop 'checked', false unless hasButton

          if not hasButton
            if not $(activeTab).parent().hasClass 'lock'
              $(activeTab).attr 'marker', $(this).attr('marker')

        # 2. Close any previously open menus - perhaps belonging to a sibling 
        for m in $(this).parent().find('.dropdown-menu') # ideally, there should be atmost one open
          menu.close $(m)

        # 3. Issue AJAX request - if defined and set on containing panel
        tab = karo.tab.find this
        if tab?
          tab = $(tab).children('a')[0] # tab was an <li>. We need the <a> within it
          ajax = karo.url.elaborate this, null, tab

          if ajax?
            pgnOn = tab.getAttribute('data-paginate-on')
            if pgnOn? and pgnOn is 'line'
              panel = $(this).closest('.g-panel')[0]
              pgn = $(panel).children('.paginator').eq(0)
              paginator.initialize(pgn, ajax, tab)
            karo.ajaxCall(ajax, tab)

        # 4. Switch to next-tab - if so specified
        if activeTab?
          # activeTab is a <li> and what we are looking for is in the <a> within it
          a = $(activeTab).children('a')[0]
          # next = a.dataset.autoclickTab
          next = a.getAttribute('data-autoclick-tab')
          karo.tab.enable next if next?

    # End of method 
    return (if m? then false else true)

  ###############################################
  # Process any :prev or :id in the about-to-be-submitted 
  # <form>'s action attribute
  # If the <form> also has data-[prev | id] attributes, then 
  # use them as guides. Else, look of :prev and :id relative 
  # to the .tab-pane within which the form is 
  ###############################################

  $('form').submit (event) ->
    # action = this.dataset.action
    action = this.getAttribute('data-action')
    return true unless action?

    # id = if this.dataset.id is "null" then null else this.dataset.id
    id = this.getAttribute('data-id')
    id = if id is "null" then null else id

    # prev = if this.dataset.prev is "null" then null else this.dataset.prev
    prev = this.getAttribute('data-prev')
    prev = if prev is "null" then null else prev

    panes = $(this).closest('.tab-content')[0]
    if panes?
      activeTab = $(panes).prev().children('li.active')[0]

    if id? and id.length > 0
      id = $("##{id}")[0]
      type = id.getAttribute('data-toggle')
      id = if type is 'tab' then $(id).parent() else $(id)
    else if activeTab?
      id = $(activeTab)

    if prev? and prev.length > 0
      prev = $("##{prev}")[0]
      type = prev.getAttribute('data-toggle')
      prev = if type is 'tab' then $(prev).parent() else $(prev)
    else if activeTab?
      prev = $(activeTab).prev()

    for j in ["prev", "id"]
      at = action.indexOf ":#{j}"
      if at isnt -1 # => is present 
        obj = if j is 'prev' then prev else id
        marker = getMarker(obj)
        action = action.replace ":#{j}", marker
    # alert action
    $(this).attr 'action', action
    return true


  #####################################################################
  ## Show tooltips on hover
  #####################################################################

  $("[rel='tooltip']").hover ->
    $(this).tooltip 'show'


  #####################################################################
  ## Auto-click the first default link 
  #####################################################################

   for m in $("#control-panel, #menus > ul[role='menu']").find("a[data-default]")
     trigger.click m
     return true


  #####################################################################
  ## http://stackoverflow.com/questions/13073357/simpleformclientsidevalidationsbootstrap-validation-is-not-occurring
  #####################################################################

  $('#m-register').on 'shown', () ->
    $(ClientSideValidations.selectors.forms).validate()
    return true
  
  $('#shopfront').on 'click', 'a', (event) ->
    event.stopImmediatePropagation(event) unless $(this).hasClass('carousel-control')
    trigger.click this
    return true
