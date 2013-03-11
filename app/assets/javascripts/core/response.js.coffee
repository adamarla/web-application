
jQuery ->

  $('#wide').ajaxComplete (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match('quiz/preview') or url.match('ws/preview')
      preview.loadJson json, 'atm'
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true

  #####################################################################
  ## Close modal for changing account details on form submit 
  #####################################################################
  
  $('#control-panel').ajaxSuccess (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match('account')
      $('#m-edit-account').modal 'hide'
    else if url.match('register')
      a = $('#m-registrations')
      m = a.next() # next = ul.dropdown-menu
      menu.close m, true
      a.parent().removeClass 'active' # parent = .dropdown
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true

  $('#control-panel').ajaxError (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match('register')
      tabContent = $('#m-registrations').next('ul').children('.tab-content').eq(0)
      active = tabContent.children('.active').eq(0)
      form = active.children('form').eq(0)
      errors = form.children('.error')

      for m in ['email', 'password']
        continue if json.errors[m].length is 0
        e = errors.filter(".#{m}").eq(0)
        e.removeClass 'hide'
        e.prev().find('p').eq(0).addClass 'hide'
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true

