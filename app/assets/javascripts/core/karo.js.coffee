
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
        continue if $(m).hasClass 'no-touch'
        if karo.checkWhether m, 'no-remove'
          $(z).empty() for z in $(m).find('.purge')
        else
          $(m).remove()
    return true

  unhide : (child, panel) -> # hide / unhide children in a panel
    for m in panel.children()
      if karo.checkWhether m, 'pagination'
        pagination.disable $(m)
        continue
      id = $(m).attr 'id'
      if id is child then $(m).removeClass('hide') else $(m).addClass('hide')
    return true

  checkWhether : (node, klass) ->
    # 'node' could be anything but is generally expected to be ul > li > a in a .nav-tabs. 
    # If either it or the grand-parent <ul> has class = klass, then return true
    # Note: If the grand-parent <ul> has class = klass, then all <a> within it 
    # do too

    nopurge = false
    if klass.match(/nopurge/)
      nopurge = true
      return true if $(node).hasClass 'nopurge-ever'

    return true if $(node).hasClass klass

    ul = $(node).closest('ul.nav-tabs').eq(0)
    return false if ul.length is 0
    if nopurge
      return true if ul.hasClass 'nopurge-ever'
    return ul.hasClass(klass)

  tab : {
    enable : (id) ->
      m = $("##{id}")
      li = m.parent()
      li.removeClass 'disabled'
      li.removeClass 'active' if li.hasClass 'active'
      m.tab 'show'
      return true

    find : (node) -> # the closest active tab within which - presumably - the node is
      pane = $(node).closest('.tab-content').eq(0)
      return null if pane.length is 0
      ul = pane.prev()
      return ul.children('li.active')[0]
  }

  url : {
    elaborate : (obj, json = null, tab = null) ->
      ajax = if tab? then tab.dataset.panelUrl else obj.dataset.url
      return ajax unless ajax? # => basically null 

      for m in ["prev", "id"]
        if ajax.indexOf ":#{m}" isnt -1 # => :prev / :id present 
          if obj.dataset[m]?
            from = $("##{obj.dataset[m]}")
          else if (tab? and tab.dataset[m]?)
            from = $("##{tab.dataset[m]}")
          else from = $(obj)

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
