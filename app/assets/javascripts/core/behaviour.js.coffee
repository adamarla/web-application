
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
      gutenberg.server = gutenberg.serverOptions.local
    
  pingargs =
  	url: '/ping'
  	success: pinghandler
  	async: false

  $.ajax pingargs

  $('html').click (event) ->
    ui = event.target
    for m in $('.g-panel')
      for p in $(m).find '.dropdown-menu'
        menu.close $(p)
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

  $('.dropdown-toggle').click (event) ->
    menu = $(this).attr 'menu' # => is an ID attribute 
    return false unless menu?
    event.stopPropagation()

    parent = $(this).parent()
    menuObj = parent.children(menu).eq(0)
    already = if menuObj.length > 0 then true else false
    
    # Links the control-panel have non-contextual - or fixed - menus. 
    # They need not be removed on every click because they aren't shared across links
    fixed = $(this).attr('fixed') is 'true'

    # if there are any other 'sibling/cousin' menus open - then remove / hide them 
    for uncle in parent.siblings()
      lnk = $(uncle).children('.dropdown-toggle').eq(0)
      siblingObj = $(uncle).children('.dropdown-menu').eq(0)
      if siblingObj.length > 0
        if lnk.attr('fixed') is 'true' then siblingObj.removeClass('show') else siblingObj.remove()

    if already
      if fixed then menuObj.addClass('show') else menuObj.remove()
    else
      # all task-lists are rendered within toolbox
      menuObj = $('#toolbox').children(menu).eq(0)
      if menuObj.length isnt 0
        newId = "#{menuObj.attr('id')}-curr" # There shouldn't be 2 elements with the same ID
        m = $(menuObj).clone()
        m.attr 'id', newId
        m.insertAfter $(this)
        m.addClass 'show'
    return true

  # Auto-click the one link in #control-panel that is identified as the default link

  for m in $('#control-panel ul.dropdown-menu > li > a')
    if $(m).attr('default') is 'true'
      $(m).click()






