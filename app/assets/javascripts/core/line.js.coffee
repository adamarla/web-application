
renderTextAndEqnsOn = (obj, text, marker) ->
  hasTex = false
  if text.search(/\$.*\$/) isnt -1 # => LaTeX
    hasTex = true
    jaxified = karo.jaxify text 
    parent = obj.parent() 
    obj.replaceWith "<div class='tex'><script id='tex-#{marker}' type='math/tex'>#{jaxified}</script></div>"
    # kinda imp. to wrap <script> within some <div>
    j = parent.find('script')[0]
    MathJax.Hub.Queue ['Typeset', MathJax.Hub, j]
  else
    obj.text text
  return hasTex

# Single line 

window.sngLine = {
  write : (here, json, menu = null, buttons = null) ->
    return false if not json.id? or not json.name?
    here = if typeof here is 'string' then $(here) else here

    ###
      Fields in the JSON that change from one .line to the next
        - name (mandatory): set as 'text' 
        - id (mandatory): set as 'marker'
        - tag (optional): written extreme right, in orange 
        - badge (optional): Eg. quiz totals 
        - klass (optional)
        - icons (optional)

      Common to all .lines rendered from the same JSON 
        - buttons (optional) 
        - menu (optional) 
    ###

    isVideo = json.video?

    obj = $('#toolbox').children('.line').eq(0).clone()
    remaining = 11

    # 1. Do the easiest first 
    if json.klass?
      obj.addClass json.klass

    obj.attr 'marker', json.id
    children = obj.children()

    # Write the main text
    label = children.filter(".text")
    hasTex = renderTextAndEqnsOn label, json.name, json.id
    if hasTex 
      children = obj.children()
      label = children.filter('.tex') 

    # Tag
    tag = children.filter(".subtext")
    if json.tag?
      tag.text json.tag
      tag.addClass 'span3'
      remaining -= 3
    else
      tag.remove()

    # Contextual menu
    m = obj.find("[data-toggle='dropdown']")[0]
    if menu?
      m.setAttribute 'data-show-menu', menu
      $(m).addClass 'span1'

      unless isVideo
        children.filter(".badge").eq(0).remove() unless json.badge? # no badge if menu and badge.empty?
    else
      $(m).parent().remove()

    # Badge
    badge = children.filter(".badge")

    if json.badge? || isVideo
      if isVideo
        useIcon = 'icon-facetime-video'
        badge.addClass 'video'
        badge.attr 'data-video', json.video
      else if typeof(json.badge) is 'string'
        useIcon = if json.badge.search(/^icon-/) isnt -1 then json.badge else null
      else
        useIcon = null

      if useIcon?
        $("<i class='#{useIcon}'></i>").appendTo badge
      else
        badge.text json.badge

      badge.addClass 'span2'
      remaining -= 2

    # Icons 
    icons = if json.icons? then json.icons.split(' ') else null
    if icons? 
      for j in icons 
        $("<i class='#{j} icon-gray pull-right'></i>").appendTo obj

    if buttons?
      for b in buttons
        k = if b.icon? then 'btn btn-mini' else (if b.klass? then "btn btn-mini #{b.klass}" else "btn btn-mini hide default")
        btn = $("<div class='#{k}'></div>")
        $("<i class='icon-white #{b.icon}'></i>").appendTo(btn) if b.icon?
        $("<input class='hide' type='checkbox' name=#{b.cbx}[#{json.id}]></input>").appendTo(btn) if b.cbx?
        btn.appendTo obj
        remaining -= 1 unless btn.hasClass('hide')

    # Stopwatch 
    watch = children.filter(".stopwatch")[0]
    $(watch).remove() unless json.timer?

#    if json.timer?
#      stopWatch.add watch
#      stopWatch.start watch, 30
#    else
#      $(watch).remove()

    # Whatever span remains, give to 'label'
    remaining = if remaining > 9 then 9 else remaining
    label.addClass("span#{remaining}") if remaining > 0

    # Done !!!
    obj.appendTo here
    return true

  hiddenCbx : (l) ->
    cbx = $(l).children('.btn.default')[0]
    return ( if cbx? then $(cbx).children("input[type='checkbox']")[0] else null )
}

### 
  All lines 
###


window.lines = {
  columnify : (here, json, menu, buttons = null) ->
    # json = array of N objects 
    here = if typeof here is 'string' then $(here) else here

    columns = here.find '.column'
    nColumns = columns.length
    perColumn = if nColumns > 0 then ((json.length / nColumns ) + 1) else json.length
    perColumn = parseInt perColumn

    currIndex = 0
    currColumn = if nColumns > 0 then columns.eq(currIndex) else here
    nAdded = 0

    for m,j in json
      if nAdded > perColumn
        currIndex += 1
        currColumn = columns.eq(currIndex)
        nAdded = 0
      sngLine.write currColumn, m, menu, buttons
      nAdded += 1
    return true

  # target, key, json, menu, buttons, clickFirst
  render : (target, key, json, menu, buttons, clickFirst) ->
    return false unless target?
    return false if target.length is 0

    writeData = if key? then true else false

    if json.last_pg?
      ###
        this next bit of code is done only for teachers and in a very specific 
        contexts - picking questions to add to a quiz - either when its 
        first being built or when its being edited subsequently

        the issue is that we would like paginator with multi-select. 
        with paginator, we can break a long list down into manageable chunks
        But multi-select requires that we retain any previously loaded data 
        and selections
      ###
      if target.hasClass 'paginator'
        if json.pg?
          page = target.children("div[page='#{json.pg}']")
          $("<div page=#{json.pg}></div>").appendTo target if page.length is 0
          target = target.children("div[page='#{json.pg}']").eq(0)
          $(m).addClass 'hide' for m in target.siblings()
          target.removeClass 'hide'
          writeData = target.children().length is 0

    # Render the returned JSON - in columns if so desired
    if writeData
      lines.columnify target, json[key], menu, buttons
      sieve.through target

    # Disable / hide any .line whose marker is in json.[disabled, hide]
    for m in ['disabled', 'hide']
      continue unless json[m]
      j = target.find('.line')
      for k in json[m]
        l = j.filter("[marker=#{k}]")[0]
        $(l).addClass(m) if l?

    # Remove any .line specified in json.remove
    if json.remove?
      j = target.find '.line'
      for k in json.remove 
        l = j.filter("[marker=#{k}]")[0]
        $(l).remove() if l?

    if json.download?
      j = target.find('.line')
      for k in json.download
        l = j.filter("[marker=#{k.id}]")[0]
        if l?
          tag = $(l).children('.subtext')[0]
          $(tag).remove() if tag?
          $("<a href=#{k.path} target=_blank>PDF</a>").appendTo($(l)) 

    # Auto-click first line - if needed
    target.children('.line').filter(":not([class~='disabled'])").eq(0).click() if clickFirst
    return true

}
