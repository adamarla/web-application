
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
  ###
    This next call is unassuming but rather important. We initialize 
    variables within the JS based on the results the server being accessed returns
  ###

  pinghandler = (response) ->
    if response.deployment is 'production'
      gutenberg.server = gutenberg.serverOptions.remote
    else
      gutenberg.server = gutenberg.serverOptions.remote
    
  pingargs =
  	url: '/ping'
  	success: pinghandler
  	async: false

  $.ajax pingargs

  $('#how-it-works').carousel({
    interval : 5000
  })

  $('html').click (event) -> # handles cases other than those handled by bindings below 
    for m in $('.g-panel')
      for p in $(m).find '.dropdown-menu'
        menu.close $(p)
    return true

  $('.g-panel').on 'click', "a[data-toggle='modal']", (event) ->
    m = $(this).attr 'href'
    $(m).modal()
    return true

  ###############################################
  # When a tab is clicked and shown
  ###############################################

  $(".g-panel").on 'click', "a[data-toggle='tab']", (event) ->
    if $(this).parent().hasClass 'disabled'
      event.stopImmediatePropagation()
      return false
    else
      return true

  $(".g-panel").on 'shown', "a[data-toggle='tab']", (event) ->
    event.stopPropagation()

    # Empty the last-enabled tab's contents - if needed
    prevTab = event.relatedTarget
    unless $(prevTab).length is 0
      unless karo.checkWhether prevTab, 'nopurge-on-inactive'
        karo.empty $(prevTab).attr('href')

    # Empty the currently-enabled tab's contents - if needed
    empty = not karo.checkWhether(this, 'nopurge-on-show')
    if empty
      karo.empty $(this).attr('href')

    # Disable paginator in parent panel 
    panel = $(this).closest('.g-panel')[0]
    pgn = $(panel).children('.pagination').eq(0)
    pagination.disable pgn

    # Issue AJAX request * after * taking care of any :prev or :id in data-url
    ajax = karo.url.elaborate this
    if ajax?
      proceed = true
      if karo.checkWhether this, 'nopurge-on-show'
        z = $($(this).attr('href'))
        proceed = z.hasClass('static') || (z.children().length is 0)
      if proceed
        karo.ajaxCall ajax
        pagination.url.set pgn, ajax

    # Set base-ajax url on containing panel
    ul = $(this).parent().parent() # => ul.nav-tabs
    unless ul.hasClass 'lock'
      panelUrl = this.dataset.panelUrl
      panel.dataset.url = if panelUrl? then panelUrl else null

    # Auto-click any autoclick links - but not tabs 
    autoLink = this.dataset.autoclickLink
    $("##{autoLink}").click() if autoLink?

    ###
      Do the next two for only * horizontal * tabs - not .tabs-left
        1. Ensure that atmost 3 tabs are shown - including the just clicked one
        2. disable all subsequent tabs 

      Left-tabs are for special use-cases and therefore one can't make a 
      blanket call on their behaviour. 
    ###

    unless $(this).closest('.tabs-left').length isnt 0
      li = $(this).parent()
      li.removeClass 'hide'

      for m in li.nextAll('li')
        $(m).addClass 'disabled'
        tab = $(m).children('a')[0]
        unless karo.checkWhether tab, 'nopurge-on-disable'
          karo.empty $(tab).attr('href')
      ###
      for m in li.siblings('li')
        $(m).addClass 'hide'

      p = li.prev('li')
      n = li.next('li')

      $(p).removeClass 'hide' if p.length isnt 0
      $(n).removeClass 'hide' if n.length isnt 0
      ###

    return true

  ###############################################
  # When an item in a dropdown menu is selected 
  ###############################################

  $('.g-panel, .content, .tab-pane, #toolbox').on 'click', '.dropdown-menu > li > a', (event) ->
    return true if this.dataset.toggle is 'tab'
    return true if $(this).hasClass 'carousel-control'

    event.stopImmediatePropagation()
    # (YAML) Hide / unhide panels as needed

    notouch = if this.dataset.notouch? then (this.dataset.notouch is 'true') else false
    unless notouch
      for j in ['left', 'right', 'middle', 'wide']
        if typeof this.dataset[j] is 'string'
          continue if this.dataset[j] is 'as-is'

        attr = "#{j}Show" # x-y in YAML => xY here
        show = this.dataset[attr] # left-show, right-show etc 
        panel = $("##{j}")
        if not show?
          panel.addClass 'hide'
          continue
        panel.removeClass 'hide'
        karo.unhide(show, panel) unless show is 'no-remove'

    # If there be a tab that needs to be auto-clicked, then do that too
    tab = this.dataset.autoclickTab
    karo.tab.enable tab if tab?

    # If <a> is within a dropdown-menu, then close the dropdown menu
    # d = $(this).closest('.dropdown-menu')
    menu.close $(this)

    # (YAML) Issue any AJAX requests
    ajax = karo.url.elaborate this
    karo.ajaxCall ajax if (ajax? and ajax isnt 'disabled')

    return true

  ###############################################
  # When the caret to open a contextual menu is clicked 
  ###############################################

  $('.dropdown-toggle').click (event) ->
    event.stopPropagation()
    menu.show this
    return true

  ###############################################
  # When a pagination link is clicked 
  ###############################################

  $('.pagination a').click (event) ->
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

  $('.content, .tab-pane').on 'click', '.single-line', (event) ->
    ###
       Yes, this method does not allow a contextual menu to open if the 
       .single-line hasnt been selected first 
    ###
    return false if $(this).hasClass 'disabled'

    clickedObj = $(event.target)
    m = null

    if clickedObj.hasClass('dropdown')
      m = clickedObj
    else if clickedObj.hasClass 'dropdown-toggle'
      m = clickedObj.parent()

    if m? # => if clicked to see dropdown menu
      event.stopImmediatePropagation()
      if m.parent().hasClass('selected') then menu.show m.find('.dropdown-toggle')[0] else return false
    else # elsewhere on the single-line => select / de-select
      event.stopPropagation()
      multiOk = $(this).parent().hasClass('multi-select') # parent = .content / .tab-pane / form
      activeTab = $(this).closest('.tab-content').prev().children('li.active')[0]
      
      # 1. De-select siblings if * not * multi-select 
      unless multiOk
        for k in $(this).siblings('.single-line')
          $(k).removeClass 'selected'
          $(k).find('.badge').eq(0).removeClass 'badge-warning'
          $(k).find("input[type='checkbox']").eq(0).prop 'checked', false

      # 2. Then select / deselect $(this)
      isClicked = $(this).hasClass 'selected'
      badge = $(this).find('.badge').eq(0)

      if isClicked
        $(this).removeClass 'selected'
        badge.removeClass 'badge-warning'
        $(this).find("input[type='checkbox']").eq(0).prop 'checked', false
        unless multiOk
          unless $(activeTab).parent().hasClass 'lock'
            $(activeTab).attr 'marker', null
      else
        $(this).addClass 'selected'
        badge.addClass 'badge-warning'
        $(this).find("input[type='checkbox']").eq(0).prop 'checked', true
        unless multiOk
          unless $(activeTab).parent().hasClass 'lock'
            $(activeTab).attr 'marker', $(this).attr('marker')

      # 3. Close any previously open menus - perhaps belonging to a sibling 
      for m in $(this).parent().find('.dropdown-menu') # ideally, there should be atmost one open
        menu.close $(m)

      # 4. Issue AJAX request - if defined and set on containing panel
      tab = karo.tab.find this
      tab = $(tab).children('a')[0] # tab was an <li>. We need the <a> within it
      ajax = karo.url.elaborate this, null, tab
      karo.ajaxCall ajax if ajax?

      # 5. Switch to next-tab - if so specified
      if activeTab?
        # activeTab is a <li> and what we are looking for is in the <a> within it
        a = $(activeTab).children('a')[0]
        next = a.dataset.autoclickTab
        karo.tab.enable next if next?

    # End of method 
    return true

  ###############################################
  # Process any :prev or :id in the about-to-be-submitted 
  # <form>'s action attribute
  # If the <form> also has data-[prev | id] attributes, then 
  # use them as guides. Else, look of :prev and :id relative 
  # to the .tab-pane within which the form is 
  ###############################################

  $('.tab-content > .tab-pane > form').submit (event) ->
    action = this.dataset.action
    return true unless action?

    activeTab = $(this).closest('.tab-content').prev().children('li.active').eq(0)

    for j in ["prev", "id"]
      at = action.indexOf ":#{j}"
      if at isnt -1 # => is present 
        obj = this.dataset[j]
        obj = if obj? then $("##{obj}").parent() else null # $(obj) is an <a>. Marker is on the parent <li>
        unless obj?
          obj = if j is "prev" then activeTab.prev() else activeTab
        action = action.replace ":#{j}", obj.attr('marker')
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

   $("#toolbox > ul[role='menu']").find("a[data-default-lnk='true']").eq(0).click()
