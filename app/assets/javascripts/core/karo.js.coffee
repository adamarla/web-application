
window.karo = {
  nothing : () ->
    return true

  ajaxCall : (url, callback = karo.nothing) ->
    $.get url, (json) ->
      callback json, url
    
  empty : (node) ->
    node = if typeof node is 'string' then $(node) else node

    csrf = if node.is 'form' then node.children().eq(0) else null
    csrf = csrf.detach() if csrf?
    
    children = node.children()

    if node.hasClass 'purge-blind'
      node.empty()
    else if node.hasClass 'purge-destroy'
      node.remove()
      return true
    else if node.hasClass 'leaf' || children.length is 0
      node.remove()
      return true
    else if node.hasClass 'purge-skip'
      csrf.prependTo node if csrf?
      return true
    else
      karo.empty $(m) for m in children

    csrf.prependTo node if csrf?
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
      return true if ($(node).hasClass('nopurge-ever') || $(node).attr('nopurge-ever') is 'true')

    if ($(node).hasClass(klass) || $(node).attr(klass) is 'true')
      return true

    ul = $(node).closest('ul.nav-tabs').eq(0)
    return false if ul.length is 0
    if nopurge
      return true if (ul.hasClass('nopurge-ever') || ul.attr('nopurge-ever') is 'true')
    return (ul.hasClass(klass) || ul.attr(klass) is 'true')

  tab : {
    enable : (obj) ->
      m = if typeof obj is 'string' then $("##{obj}")[0] else obj
      li = $(m).parent()
      li.removeClass 'disabled'
      li.removeClass 'active' if li.hasClass 'active'
      $(m).tab 'show'
      trigger.click m
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

  sanitize : (comment) ->
    ret = comment.replace /[\$]+/g, '$' # -> all TeX within $..$ (inlined)
    # ret = ret.replace /(\\frac)/g, "\\dfrac" # \dfrac looks better on annotation

    # Make sure that all $'s are paired. Remember, the value this function returns 
    # is what will be typeset remotely. Can't have LaTeX barf there
    nDollar = (ret.match(/\$/g) || []).length

    if nDollar % 2 isnt 0 # => odd # of $ => mismatched
      ret += "$"
    return ret

  jaxify : (comment) ->
    ###
      The comment entered in the comment box is assumed to be more of regular 
      text with bits of inline-TeX thrown in ( enclosed between $..$ that is)

      But MathJax expects TeX that is more of TeX with bits of regular 
      text thrown in (enclosed between \text{...})

      This method does that conversion from the user assumes and enters 
      to what MathJax assumes and renders
    ###

    text = true
    latex = false
    z = "\\text{"

    for m in comment
      if text
        if m is '$' # opening $
          text = false
          latex = true
          z += " }"
        else
          z += m
      else if latex
        if m is '$' # => closing $
          text = true
          latex = false
          z += "\\text{ "
        else
          z += m
    z += "}" if text
    return z
    

}
