
window.karo = {
  nothing : () ->
    return true

  ajaxCall : (url, tab = null, callback = karo.nothing) ->
    $.get url, (json) ->
      if tab?
        if json.ping? 
          monitor.tabs.active = $(tab).closest('ul')[0]
          monitor.tabs.refreshSiblingsOf(tab)
          monitor.tabs.update tab, json.ping

        pgn = $(tab).closest('.g-panel').children('.paginator')[0]
        if pgn?
          if json.last_pg? 
            last = json.last_pg
            tab.setAttribute('data-pg-last', last)
            paginator.enable $(pgn), last
      # callback json, url
    #return true
    
  empty : (node) ->
    node = if typeof node is 'string' then $(node) else node

    csrf = if node.is 'form' then node.children().eq(0) else null
    csrf.detach() if csrf?
    
    if karo.check.precious(node) 
      karo.empty( $(j) ) for j in node.children()
    else 
      node.remove() 
    csrf.prependTo(node) if csrf?
    return true

  unhide : (child, panel) -> # hide / unhide children in a panel
    for m in panel.children()
      if $(m).hasClass('paginator') 
        paginator.disable $(m)
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

  check : { 
    precious : (node) ->
      for k in ['line', 'criterion']
        return false if node.hasClass(k)
      return true
  } 

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
  }

  find : { 
    tab : (node) -> # closest active tab within which - presumably - the node is 
      pane = $(node).closest('.tab-content')[0]
      return null unless pane?
      ul = $(pane).prev() 
      return ul.children('li.active').eq(0).children('a')[0]

    pane : (tab) -> # pane corresponding to passed tab
      return null unless tab.getAttribute('data-toggle') is 'tab'
      href = $(tab).attr('href').slice(1) # get rid of leading #
      ul = $(tab).closest('.nav-tabs')
      lookIn = ul.next() # should be a .tab-content
      return lookIn.find("[id=#{href}]")[0]
  } 

  link : {
    disable : (a) -> 
      $(a).addClass 'disabled' 
      i = $(a).children('i')[0]
      if i? 
        $(i).removeClass 'icon-white'
        $(i).addClass 'icon-gray' 
      return true

    enable : (a) ->
      $(a).removeClass 'disabled' 
      i = $(a).children('i')[0]
      if i? 
        $(i).removeClass 'icon-gray'
        $(i).addClass 'icon-white' 
      return true
  }

  url : {
    updateOnAjax : (a, url, json) ->
      # continue unless a.dataset.ajax is 'disabled'
      # updateOn = a.dataset.updateOn
      updateOn = a.getAttribute('data-update-on')

      return false unless updateOn?
      return false unless karo.url.match(url, updateOn)

      disable = false 
      key = a.getAttribute('data-disable-if')
      if key?
        disable = if json[key]? then json[key] else false
      else
        key = a.getAttribute('data-disable-unless')
        if key? 
          disable = if json[key]? then !json[key] else true

      if disable
        karo.link.disable a
        return false
      else
        karo.link.enable a

      href = karo.url.elaborate a, json
      return false unless href?
      $(a).attr 'href', href
      return true

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
    # Remove whitespace from front and back => trim()  
    j = comment.replace(/^\s+|\s+$/g,'')

    # Replace > 1 continuous spaces with a single space 
    k = j.replace(/\s\s+/g,' ')

    # Replace any continous occurrences of $ - like $$ - with a single $
    ret = k.replace /[\$]+/g, '$' # -> all TeX within $..$ (inlined)

    # Make sure that all $'s are paired. Remember, the value this function returns 
    # is what will be typeset remotely. Can't have LaTeX barf there
    nDollar = (ret.match(/\$/g) || []).length

    ret += "$" if nDollar % 2 isnt 0 # => odd number of $ => mismatched $..$ 
    return ret

  isPlainTextCheck : (comment) ->
    # Either a string is plain text - that is, no LaTeX - or it has LaTeX
    # The passed 'comment' is jaxified and comes from the DB 
    z = comment.replace(/\\text{\s+.*?\s+}/, "")
    return z.length == 0 # if nothing remains after removing all \text{ ... }, then its plain text 

  jaxify : (comment) ->
    # Converts "A $B$ C $D$" as written by the user to "\text{ A }B\text{ C }D" as MathJax expects

    comment = comment.replace(/\$\$/, '').trim() # get rid of empty $..$ pairs
    mathFilter = /\$.*?\$/g
    ret = new String(comment)
    pureText = true

    while((mathBits = mathFilter.exec(comment)) != null)
      pureText = false
      bit = mathBits[0]
      j = bit.replace(/^\$/,'}')
      j = j.replace(/\$/,'\\text{ ')
      ret = ret.replace bit, j

    if pureText 
      ret = "\\text{ #{ret} }"
    else 
      ret = ret.replace(/^/, '\\text{ ')
      ret = ret.concat ' }'
      ret = ret.replace(/\\text{\s+}/g,'')
    return ret
    
  unjaxify: (comment) ->
    # Reverses what karo.jaxify does 
    # Converts "\text{ A }B\text{ C }D" - which is what is stored in the DB and used by MathJax 
    # to "A $B$ C $D$" - which is how the user originally entered it

    mathFilter = /(}|^).*?(\\text{|$)/g
    ret = new String(comment)

    while((mathBits = mathFilter.exec(comment)) != null)
      bit = mathBits[0]
      j = bit.replace(/^}|^/,'$')
      j = j.replace(/$|\\text{/,'$')
      if j isnt '$$'
        ret = ret.replace(bit,j)
      else
        ret = ret.replace(bit,'') if bit is '\\text{'

    ret = ret.replace /}$/, ''
    ret = karo.sanitize ret
    return ret

}
