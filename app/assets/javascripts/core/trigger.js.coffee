
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
    ui = event.target
    for m in $('.g-panel')
      for p in $(m).find '.dropdown-menu'
        menu.close $(p) unless $(p).parent().hasClass('dropdown-submenu')
    return true

  ###############################################
  # Onto core bindings 
  ###############################################

  #for m in $('#desktop').children()
  #  $(m).addClass 'hide'

  $('.dropdown-menu').on 'click', 'li > a', (event) ->
    for j in ['lp','mp','rp','wp'] # lp = left-panel, mp = middle-panel, rp = right-panel, wp = wide-panel
      show = $(this).attr j
      continue unless show?
      for m in show.siblings()
        $(m).addClass 'hide'
      show.removeClass 'hide'
    return true


  $('.content, .tab-pane').on 'click', '.dropdown-menu > li > a', (event) ->
    tabs = this.dataset.tabs
    if tabs?
      within = $(this).closest '.tab-content'
      nav = if within.length isnt 0 then within.prev() else null # should be a .nav-tabs. If not, then sth is wrong
      if nav?
        indices = tabs.split ','
        activate = "li:eq(#{indices[0]}) > a"
        nav.find(activate).eq(0).tab 'show'
    return true

  $('.dropdown-toggle').click (event) ->
    event.stopPropagation()
    menu.show $(this)
    return true

  # Auto-click the one link in #control-panel that is identified as the default link

  for m in $('#control-panel ul.dropdown-menu > li > a')
    if $(m).attr('default') is 'true'
      $(m).click()

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

    if m?
      event.stopImmediatePropagation()
      if m.parent().hasClass('selected') then menu.show m.find('.dropdown-toggle').eq(0) else return false
    else
      for k in $(this).siblings('.single-line')
        $(k).removeClass 'selected'
      $(this).addClass 'selected'
      # Close any previously open menus - perhaps belonging to a sibling 
      for m in $(this).parent().find('.dropdown-menu') # ideally, there should be atmost one open
        menu.close $(m)
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
  ###
  $("a[data-toggle='tab']").on 'shown', (event) ->
    ajax = this.dataset.ajax
    $.get ajax if ajax?
    # disable any paginator coz it will be re-enabled in response to the AJAX request
    pgn = $(this).closest('.g-panel').find('.pagination').eq(0)
    pagination.disable pgn if pgn.length isnt 0
    return true
