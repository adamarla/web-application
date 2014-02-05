
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

  match : (node, klass) ->
    # Checks for passed 'klass' as class, attr or data-* attribute on the passed node
    return true if $(node).hasClass klass
    return true if $(node).attr(klass) is 'true'
    return true if node.getAttribute("data-#{klass}") is 'true'
    return false

  checkWhether : (node, klass) ->
    # 'node' could be anything but is generally expected to be ul > li > a in a .nav-tabs. 
    # If either it or the grand-parent <ul> has class = klass, then return true
    # Note: If the grand-parent <ul> has class = klass, then all <a> within it 
    # do too

    nopurge = false
    matches = karo.match(node, klass)
    return true if matches

    if klass.match(/nopurge/)
      nopurge = true
      return true if karo.match(node, 'nopurge-ever')

    # If not on node, then check on parent <ul> - if any
    ul = $(node).closest('ul.nav-tabs')[0]
    return false if $(ul).length is 0
    if nopurge
      return true if karo.match(ul, 'nopurge-ever')
    return karo.match(ul, klass)

  tab : {
    enable : (obj) ->
      m = if typeof obj is 'string' then $("##{obj}")[0] else obj

      li = $(m).parent()
      li.removeClass 'disabled'
      li.removeClass 'active' if li.hasClass 'active'
      $(m).tab 'show'
      trigger.click(m)
      return true

    find : (node) -> # the closest active tab within which - presumably - the node is
      pane = $(node).closest('.tab-content').eq(0)
      return null if pane.length is 0
      ul = pane.prev()
      return ul.children('li.active')[0]
  }

  url : {
    elaborate : (obj, json = null, tab = null) ->
      ajax = if tab? then tab.getAttribute('data-url-panel') else obj.getAttribute('data-url-self')

      return ajax unless ajax? # => basically null 

      updateOn = obj.getAttribute 'data-update-on'
      if updateOn? # if <a> within a dropdown-menu that has updateOn
        unless json? # if json != null, then its time to re-evaluate href
          href = $(obj).attr('href')
          if href?
            if href isnt '#'
              # There is a menu within #toolbox that is updated. And it is this that 
              # is cloned and attached when 'more...' is clicked. However, to issue 
              # an AJAX request when an <a> within the *** clone *** is clicked, it 
              # is imperative to reset the href to '#'
              $(obj).attr('href', '#')
              return href
            else
              return null

      for m in ["prev", "id"]
        if ajax.indexOf ":#{m}" isnt -1 # => :prev / :id present 
          a = obj.getAttribute "data-#{m}"
          b = if tab? then tab.getAttribute("data-#{m}") else null
          if a?
            from = $("##{a}")
          else if b?
            from = $("##{b}")
          else from = $(obj)

          marker = from.attr 'marker'
          marker = if marker? then marker else from.parent().attr('marker')
          ajax = ajax.replace ":#{m}", marker

      if json?
        for key in ['a', 'b', 'c', 'd', 'e'] # You really shouldnt have > 5 placeholders in a URL
          break unless json[key]? # no :b if no :a, no :c if no :b etc
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

    ret += "$" if nDollar % 2 isnt 0 # => odd number of $ => mismatched $..$ 
    return ret

  jaxify : (comment) ->
    ###
      Takes a TeX comment that a grader enters (something like this )
        Why shouldn't it be $\binom{5}{2}$?

      and converts it to what MathJax expects and what is eventually stored in the DB (something like this )
        \text{ Why shouldn't it be }\binom{5}{2}\text{ ?}
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

  unjaxify: (comment) ->
    # Reverses what karo.jaxify does 
    c = decodeURIComponent comment
    textRegExp = /\\text{.*?}/g

    while((arr = textRegExp.exec(c)) != null)
      text = arr[0].replace /^\\text{/, ""
      text = text.replace /}$/, ""
      text = text.trim()

      if arr.index is 0 # comment started with \text{ .... }
        c = c.replace arr[0], "#{text}$" 
      else
        c = c.replace arr[0], "$#{text}$"
    return c

}
