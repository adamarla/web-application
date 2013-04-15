
window.menu = {
  close : (m, force = false) ->
    menu = m.closest(".dropdown-menu[role='menu']").eq(0)
    if menu.hasClass 'force-close'
      return false unless force
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
        # continue unless a.dataset.ajax is 'disabled'
        updateOn = a.dataset.updateOn

        continue unless updateOn?
        continue unless karo.url.match(url, updateOn)

        href = karo.url.elaborate a, json
        continue unless href?
        $(a).attr 'href', href
    return true
}

jQuery ->

  # Update any non-ajax URLs in #toolbox-menus. These menus would cloned and 
  # re-attached later - by which time their href's should be in order 

  $('body').ajaxSuccess (e,xhr,settings) ->
    url = settings.url
    json = $.parseJSON xhr.responseText

    menu.update json, url
    return true

