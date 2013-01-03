
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

window.menu = {
  close : (m) ->
    menu = m.closest(".dropdown-menu[role='menu']").eq(0)
    toolboxed = menu.parent().attr('id') is 'toolbox'
    return true if toolboxed
    menu.remove()
    return true

  show : (m) ->
    menu = m.dataset.menu
    return false unless menu?

    # all menus are rendered within #toolbox 
    menuObj = $('#toolbox').find("##{menu}").eq(0)
    if menuObj.length isnt 0
      newId = "#{menuObj.attr('id')}-curr" # There shouldn't be 2 elements with the same ID
      newObj = $(menuObj).clone()
      newObj.attr 'id', newId
      newObj.insertAfter $(m)
      newObj.addClass 'show'
    return true

  update : (json, url) ->
    for menu in $("#toolbox > ul[role='menu']")
      for a in $(menu).find 'a'
        continue unless a.dataset.ajax is 'disabled'
        updateOn = a.dataset.updateOn

        continue unless updateOn?
        continue unless karo.url.match(url, updateOn)

        href = karo.url.elaborate a, json
        continue unless href?
        $(a).attr 'href', href
    return true
}

window.karo = {
  nothing : () ->
    return true

  ajaxCall : (url, callback = karo.nothing) ->
    $.get url, (json) ->
      callback json, url
    
  empty : (node) ->
    node = if typeof node is 'string' then $(node) else node

    if node.is 'form'
      csrf = node.children('div').eq(0) # retain cross-site forgery protection
      csrf = csrf.detach()
      node.empty()
      csrf.appendTo node
    else
      for m in node.children()
        if $(m).hasClass 'no-remove'
          $(z).empty() for z in $(m).find('.purge')
        else
          $(m).remove()
    return true

  unhide : (child, panel) -> # hide / unhide children in a panel
    for m in panel.children()
      if $(m).hasClass 'pagination'
        pagination.disable $(m)
        continue
      id = $(m).attr 'id'
      if id is child then $(m).removeClass('hide') else $(m).addClass('hide')
    return true

  tab : {
    enable : (id) ->
      m = $("##{id}")
      m.parent().removeClass 'active' if m.parent().hasClass 'active'
      m.tab 'show'
      return true

    find : (node) -> # the closest active tab within which - presumably - the node is
      node = if typeof node is 'string' then $(node) else node
      pane = node.closest('.tab-content').eq(0)
      return null if pane.length is 0
      ul = pane.prev()
      return ul.children('li.active').eq(0)
  }

  url : {
    elaborate : (obj, json = null) ->
      # obj = this where called and this = <a> with data-* attributes
      # This method simply fills in the placeholders - :id, :prev, :a, :b etc - 
      # in the data-url and returns the fully formed ajax url to call

      ajax = obj.dataset.url
      return ajax unless ajax? # => basically null 

      for m in ["prev", "id"]
        if ajax.indexOf ":#{m}" isnt -1 # => :prev / :id present 
          from = if obj.dataset[m]? then $("##{obj.dataset[m]}") else $(obj)
          marker = from.attr 'marker'
          marker = if marker? then marker else from.parent().attr('marker')
          ajax = ajax.replace ":#{m}", marker

      if json?
        for key in ['a', 'b', 'c', 'd', 'e'] # You really shouldnt have > 5 placeholders in a URL
          break unless json[key]? # no :b if no :a, no :b if no :c etc
          while ajax.search(":#{key}") isnt -1
            ajax = ajax.replace ":#{key}", json[key]
      return ajax

    match : (url, updateOn) ->
      tokens = updateOn.split ' '
      for tk in tokens
        return true if url.match tk
      return false
  }
}

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

  $('html').click (event) -> # handles cases other than those handled by bindings below 
    for m in $('.g-panel')
      for p in $(m).find '.dropdown-menu'
        # menu.close $(p) unless $(p).parent().hasClass('dropdown-submenu')
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
    unless $(event.target).closest('.nav-tabs').eq(0).hasClass 'nopurge-on-show'
      prevTab = $(event.relatedTarget)
      karo.empty prevTab.attr('href') unless prevTab.length is 0

    # Disable paginator in parent panel 
    panel = $(this).closest('.g-panel')[0]
    pgn = $(panel).children('.pagination').eq(0)
    pagination.disable pgn

    # Issue AJAX request * after * taking care of any :prev or :id in data-url
    ajax = karo.url.elaborate this
    if ajax?
      proceed = true
      if $(this).hasClass 'writeonce'
        proceed = $($(this).attr('href')).children().length is 0
      if proceed
        karo.ajaxCall ajax
        pagination.url.set pgn, ajax
      
    ###
    ajax = this.dataset.url
    if ajax?
      proceed = true
      if $(this).hasClass 'writeonce'
        proceed = $($(this).attr('href')).children().length is 0

      if proceed
        # Remember - :prev and :id point to an <a>. The marker, however, is set on the parent <li>
        for ph in ["prev", "id"]
          if ajax.indexOf ":#{ph}" isnt -1 # => :prev / :id present 
            from = if this.dataset[ph]? then $("##{this.dataset[ph]}") else $(this)
            marker = from.attr 'marker'
            marker = if marker? then marker else from.parent().attr('marker')
            ajax = ajax.replace ":#{ph}", marker
        karo.ajaxCall ajax
        pagination.url.set pgn, ajax
    ###

    # Set base-ajax url on containing panel
    ul = $(this).parent().parent() # => ul.nav-tabs
    unless ul.hasClass 'lock'
      panelUrl = this.dataset.panelUrl
      panel.dataset.url = if panelUrl? then panelUrl else null

    # Auto-click any autoclick links - but not tabs 
    autoLink = this.dataset.autoclickLink
    $("##{autoLink}").click() if autoLink?

    ###
      Ensure that atmost 3 tabs are shown - including the just clicked one
      Which means - show the current, previous (if present) and the next ( if present )

      However, do this only for horizontal tabs - not .tabs-left
    ###

    unless $(this).closest('.tabs-left').length isnt 0
      li = $(this).parent()
      for m in li.siblings('li')
        $(m).addClass 'hide'

      p = li.prev('li')
      n = li.next('li')

      $(p).removeClass 'hide' if p.length isnt 0
      $(n).removeClass 'hide' if n.length isnt 0

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
      panel = $(this).closest('.g-panel')[0]
      ajax = panel.dataset.url
      unless ajax is 'null'
        if activeTab?
          id = activeTab.dataset.id || $(this).attr('marker')
          url = ajax.replace ":id", id
          prev = if activeTab.dataset.prev? then $(activeTab.dataset.prev) else $(activeTab).prev()
          url = url.replace ":prev", prev.attr('marker') if prev.length isnt 0
          karo.ajaxCall url, menu.update

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

   for m in $('#toolbox > .dropdown-menu')
     n.click() for n in $(m).find("a[data-default-lnk='true']").eq(0)

