
window.menu = {
  close : (m, force = false) ->
    if m.is "ul"
      menu = m
    else if m.is "a"
      menu = m.closest("ul[role='menu']").eq(0)
    else if m.is "li"
      menu = m.children("ul[role='menu']").eq(0)
    else menu = null

    return false unless menu?

    # menu = m.closest(".dropdown-menu[role='menu']").eq(0)
    if menu.hasClass 'force-close'
      return false unless force

    # If doing an auto-click, like when we click a default-link, no menu 
    # is opened and therefore no menu needs to be closed
    inMenu = menu.parent().attr('id') is 'menus'
    return true if inMenu
    menu.remove()
    return true

  show : (m) ->
    # menu = m.dataset.menu
    menu = m.getAttribute('data-show-menu')
    return false unless menu?

    open = $(m).siblings("ul[role='menu']").length > 0
    return false if open # menu already open. Do nothing

    # all menus are rendered within #menus 
    menuObj = $('#menus').find("##{menu}").eq(0)
    if menuObj.length isnt 0
      newId = "#{menuObj.attr('id')}-curr" # There shouldn't be 2 elements with the same ID
      newObj = $(menuObj).clone()
      newObj.attr 'id', newId
      newObj.insertAfter $(m)
      newObj.addClass 'show'
    return true

  update : (json, url) ->
    for menu in $("#menus > ul[role='menu']")
      for a in $(menu).find 'a'
        karo.url.updateOnAjax a, url, json 
    return true
}

jQuery ->

  # Update hrefs of <a> that have data-update-on 
  # Most of these <a> are within menus. But some could be outside also 

  $('body').ajaxSuccess (e,xhr,settings) ->
    url = settings.url
    json = $.parseJSON xhr.responseText

    menu.update json, url
    karo.url.updateOnAjax(a, url, json) for a in $('#modals').find('a')
    return true

