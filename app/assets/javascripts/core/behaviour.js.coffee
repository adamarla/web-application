
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
      gutenberg.server = gutenberg.serverOptions.local
    
  pingargs =
  	url: '/ping'
  	success: pinghandler
  	async: false

  $.ajax pingargs

  ###############################################
  # Onto core bindings 
  ###############################################

  for m in $('#desktop').children()
    $(m).addClass 'hide'

  $('.dropdown-menu').on 'click', 'li > a', (event) ->
    event.stopPropagation()
    for j in ['lp','mp','rp','wp']
      continue unless $(this).hasAttr j
      show = $(this).attr j
      for m in show.siblings()
        $(m).addClass 'hide'
      show.removeClass 'hide'
    return true

  $('.dropdown-toggle').click (event) ->
    event.stopPropagation()
    tasks = $(this).attr 'task_list'
    return false unless tasks?

    parent = $(this).parent()
    already = if parent.children(tasks).length is 0 then false else true
    if already
      parent.children(tasks).eq(0).remove()
    else
      # if there are any other 'sibling/cousin' menus open - then remove them 
      for uncle in parent.siblings()
        menu = $(uncle).children('.dropdown-menu').eq(0)
        menu.remove() if menu?
      # all task-lists are rendered within toolbox
      tasks = $('#toolbox').children tasks
      if tasks.length isnt 0
        m = tasks.clone()
        m.appendTo $(this).parent()
        m.addClass 'show'
    return true

  $('.g-panel').focusout (event) -> # close all open menus when a panel loses focus
    event.stopPropagation()
    for m in $(this).find '.dropdown-menu'
      $(m).remove()
    return true




