
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
    return false if not m.hasClass 'dropdown-menu'
    lnk = m.prev() # .dropdown-toggle <- .dropdown-menu
    if lnk.attr('fixed') is 'true'
      m.removeClass 'show'
    else
      # alert "Removing #{m.attr 'id'}" if m.attr('id')?
      m.remove()
    return true

  show : (m) ->
    return false unless m.hasClass('dropdown-toggle')
    menu = m.attr 'menu' # => is an ID attribute 
    return false unless menu?
    # alert menu

    parent = m.parent()
    menuObj = parent.children(menu).eq(0)
    already = if menuObj.length > 0 then true else false
    
    # Links the control-panel have non-contextual - or fixed - menus. 
    # They need not be removed on every click because they aren't shared across links
    fixed = m.attr('fixed') is 'true'

    # if there are any other 'sibling/cousin' menus open - then remove / hide them 
    up = m.attr 'up'
    up = if up? then parseInt(up) else 1
    for z in [0 ... up-1]  # we have already gone one-level up
      parent = parent.parent()

    for uncle in parent.siblings()
      lnk = $(uncle).find('.dropdown-toggle').eq(0)
      siblingObj = $(uncle).find('.dropdown-menu').eq(0)
      if siblingObj.length > 0
        if lnk.attr('fixed') is 'true' then siblingObj.removeClass('show') else siblingObj.remove()

    if already
      if fixed then menuObj.addClass('show') else menuObj.remove()
    else
      # all task-lists are rendered within toolbox
      menuObj = $('#toolbox').children(menu).eq(0)
      if menuObj.length isnt 0
        newId = "#{menuObj.attr('id')}-curr" # There shouldn't be 2 elements with the same ID
        newObj = $(menuObj).clone()
        newObj.attr 'id', newId
        newObj.insertAfter m
        newObj.addClass 'show'
    return true
}

window.karo = {
  empty : (node) ->
    node = if typeof node is 'string' then $(node) else node
    if node.is 'form'
      csrf = node.children('div').eq(0) # retain cross-site forgery protection
      csrf = csrf.detach()
      node.empty()
      csrf.appendTo node
    else
      for m in node.children()
        continue if $(m).hasClass 'notouch'
        $(m).remove()
    return true

  unhide : (child, panel) -> # hide / unhide children in a panel
    for m in panel.children()
      if $(m).hasClass 'pagination'
        pagination.disable $(m)
        continue
      id = $(m).attr 'id'
      if id is child
        $(m).removeClass 'hide'
        karo.tab.enable panel
      else
        $(m).addClass 'hide'
    return true

  tab : {
    enable : (panel, n = 0) ->
      panel = if typeof panel is 'string' then $(panel) else panel
      first = null
      for m in panel.children()
        continue if $(m).hasClass 'hide'
        continue if $(m).hasClass 'pagination'
        first = $(m)
        break

      return true unless first?
      ul = first.children('ul.nav-tabs').eq(0)
      return true if ul.length is 0
      li = ul.children('li').eq(n)
      li.children('a').eq(0).tab 'show'
      return true
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

  $('html').click (event) ->
    for m in $('.g-panel')
      for p in $(m).find '.dropdown-menu'
        menu.close $(p) unless $(p).parent().hasClass('dropdown-submenu')
    return true

  ###############################################
  # Onto core bindings 
  ###############################################

  $("a[data-toggle='tab']").on 'shown', (event) ->
    event.stopPropagation()

    # Empty the last-enabled tab's contents
    prevTab = $(event.relatedTarget)
    karo.empty prevTab.attr('href') unless prevTab.length is 0

    # Disable paginator in parent panel 
    panel = $(this).closest('.g-panel')[0]
    pgn = $(panel).children('.pagination').eq(0)
    pagination.disable pgn

    # Issue AJAX request
    ajax = this.dataset.ajax
    $.get ajax if ajax?

    # Set base-ajax url on containing panel
    panelAjax = this.dataset.panelAjax
    panel.dataset.ajax = if panelAjax? then panelAjax else null
    return true

  $('.g-panel').on 'click', "a", (event) ->
    return true if this.dataset.toggle is 'tab'
    event.stopPropagation()
    # (YAML) Hide / unhide panels as needed
    for j in ['left', 'right', 'middle', 'wide']
      attr = "#{j}Show" # x-y in YAML => xY here
      show = this.dataset[attr] # left-show, right-show etc 
      panel = $("##{j}")
      if not show?
        panel.addClass 'hide'
        continue
      panel.removeClass 'hide'
      karo.unhide(show, panel) unless show is 'notouch'

    # (YAML) Issue any AJAX requests
    ajax = this.dataset.ajax
    $.get ajax if ajax?
    return true


  ###
  $('.dropdown-menu').on 'click', 'li > a', (event) ->
    for j in ['lp','mp','rp','wp'] # lp = left-panel, mp = middle-panel, rp = right-panel, wp = wide-panel
      show = $(this).attr j
      continue unless show?
      for m in show.siblings()
        $(m).addClass 'hide'
      show.removeClass 'hide'
    return true


  $('.content, .tab-pane').on 'click', '.dropdown-menu > li > a', (event) ->
    nextTab = this.dataset.nextTab
    if nextTab?
      within = $(this).closest '.tab-content'
      nav = if within.length isnt 0 then within.prev() else null # should be a .nav-tabs. If not, then sth is wrong
      if nav?
        #indices = nextTab.split ','
        activate = "li:eq(#{nextTab}) > a"
        nav.find(activate).eq(0).tab 'show'
    return true
  ###

  $('.dropdown-toggle').click (event) ->
    event.stopPropagation()
    menu.show $(this)
    return true

  # Auto-click the one link in #control-panel that is identified as the default link

  for m in $('#control-panel ul.dropdown-menu > li > a')
    $(m).click() if m.dataset.defaultLnk is 'true'

  $('.pagination a').click (event) ->
    event.stopPropagation()
    li = $(this).parent()
    return false if li.hasClass 'disabled'
    for m in li.siblings 'li'
      $(m).removeClass 'active'
    li.addClass 'active'
    $.get $(this).attr 'href'
    return false # already issued AJAX GET request. No need for further processing

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
      if m.parent().hasClass('selected') then menu.show m.find('.dropdown-toggle').eq(0) else return false
    else
      multiOk = $(this).parent().hasClass('multi-select') # parent = .content / .tab-pane / form
      activeTab = null
      event.stopPropagation()

      unless multiOk
        activeTab = $(this).closest('.tab-content').prev().children('li.active').eq(0)
        for k in $(this).siblings('.single-line')
          $(k).removeClass 'selected'
          $(k).find("input[type='checkbox']").eq(0).prop 'checked', false

      isClicked = $(this).hasClass 'selected'
      if isClicked
        $(this).removeClass 'selected'
        $(this).find("input[type='checkbox']").eq(0).prop 'checked', false
        activeTab.attr 'marker', null if activeTab? # => multiOk = false
      else
        $(this).addClass 'selected'
        $(this).find("input[type='checkbox']").eq(0).prop 'checked', true
        activeTab.attr 'marker', $(this).attr('marker') if activeTab?

      # Close any previously open menus - perhaps belonging to a sibling 
      for m in $(this).parent().find('.dropdown-menu') # ideally, there should be atmost one open
        menu.close $(m)

      # Last step: Issue AJAX request - if defined and set on containing panel
      panel = $(this).closest('.g-panel')[0]
      ajax = panel.dataset.ajax
      unless ajax is 'null'
        ###
          ajax is the base-url with :id and/or :prev placeholders
          :id is * always * replaced with the current .single-line's marker
          and :prev - if present - * always * with the previous tab's marker

          Presence of :prev => tabbed content
        ###
        
        url = ajax.replace ":id", $(this).attr('marker')
        prev = if activeTab? activeTab.prev() else null
        url = url.replace ":prev", prev.attr('marker') if prev?
        $.get url

    # End of method 
    return true


  ###
    Each .dropdown-menu is responsible for updating links within it when an AJAX response
    is received
    The AJAX responses a menu responds to are declared in the HTML as a 'data-autoupdate-on' 
    attribute on the .dropdown-menu
  ###

  urlsMatch = (url, updateOn) ->
    tokens = updateOn.split ' '
    for tk in tokens
      return true if url.match tk
    return false

  $('.dropdown-menu').ajaxSuccess (e, xhr, settings) ->
    updateOn = this.dataset.updateOn
    return true unless updateOn?

    json = $.parseJSON xhr.responseText
    url = settings.url
    proceed = urlsMatch url, updateOn
    return true unless proceed is true

    for a in $(this).find 'a'
      u = a.dataset.updateOn
      continue unless u
      continue unless urlsMatch(url, u)

      href = a.dataset.url
      continue unless href? # => :data => { :url => non-empty }

      for key in ['a', 'b', 'c', 'd', 'e'] # You really shouldnt have > 5 placeholders in a URL
        break unless json[key]?
        while href.search(":#{key}") isnt -1
          href = href.replace ":#{key}", json[key]
      $(a).attr 'href', href # Set the new href
    return true
    
  ###
    Issue AJAX requests - if needed - when a tab is shown so that required data can be loaded
    Also handles the case when:
      1. a tab is shown within a tab
  # $(".g-panel").on 'shown', "a", (event) ->
  $("a[data-toggle='tab']").on 'shown', (event) ->
    prevTab = $(event.relatedTarget)
    karo.empty prevTab.attr('href') unless prevTab.length is 0

    ajax = this.dataset.ajax
    $.get ajax if ajax?
    # disable any paginator coz it will be re-enabled in response to the AJAX request
    pgn = $(this).closest('.g-panel').find('.pagination').eq(0)
    pagination.disable pgn if pgn.length isnt 0

    # Attach any partial from the toolbox into corresponding panel - as specified (optionally) 
    # by the 'data-attach' attribute
    attach = this.dataset.attach
    if attach?
      panel = $(this).closest('.nav-tabs').next().children('.tab-pane.active').eq(0)
      if panel.length isnt 0
        karo.empty panel
        obj = $("#toolbox > #{attach}").clone()
        obj.appendTo panel

    return true
  ###
