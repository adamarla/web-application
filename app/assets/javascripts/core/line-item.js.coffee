

### 
  Single line 
###

window.line = {
  write : (here, json, menu, buttons = null) ->
    here = if typeof here is 'string' then $(here) else here

    ###
      Passed JSON is assumed to have atleast the following keys
        name: written as the first line 
        id: set as 'marker' attribute 
        klass (optional) : Set on the .single-line as a class attribute - if provided
    ###
    # type = if json.tag? then '.two-line' else ''

    obj = $('#toolbox').children('.single-line').eq(0).clone()
    obj.addClass(json.klass) if json.klass?
    elements = obj.children()

    mn = bdg = lngBdg = sbTxt = false
    spanLeft = 11

    # Set the menu(string) as an attribute on .dropdown > a - if provided
    toggle = obj.find('.dropdown-toggle')[0]
    dropDown = $(toggle).parent()

    if menu?
      toggle.dataset.menu = menu
      dropDown.addClass 'offset1'
      spanLeft -= 3
      mn = true
    else
      dropDown.remove()
    
    ###
      If there are buttons, then remove the following to make space 
        1. .subtext & .long-badge
        2. any other input[type='checkbox']
        3. long-badge
    ###
    if buttons?
      $(m).remove() for m in obj.children(".subtext")
      $(m).remove() for m in obj.children(".long-badge")
      $(m).remove() for m in obj.children("input[type='checkbox']")

      buttonsToKeep = if typeof buttons is 'string' then [buttons] else buttons # turn into an array
      for m in obj.children('button')
        i = $(m).children().eq(0)
        for k in buttonsToKeep
          if i.hasClass k
            spanLeft -= 1
            continue
          else
            i.parent().remove()
    else
      $(m).remove() for m in obj.children('button')
    
    text = obj.children(".text").eq(0)

    # If JSON has :badge 
    if json.long?
      b = obj.children('.long-badge').eq(0)
      if b.length isnt 0
        b.text json.long
        spanLeft -= (if mn then 1 else 2)
        b.addClass 'offset1' unless mn
        lngBdg = true
    else
      b = obj.children('.badge').eq(0)
      b.text json.badge if b.length isnt 0
      spanLeft -= (if mn then 1 else 2)
      b.addClass 'offset1' unless mn
      b.removeClass 'span1' unless json.badge?
      bdg = true

    $(m).remove() for m in obj.children('.badge') if lngBdg
    $(m).remove() for m in obj.children('.long-badge') if bdg

    # Write contents of JSON 
    text = obj.children(".text").eq(0)

    if json.name.search(/\$.*\$/) isnt -1 # => LaTeX
      jaxified = karo.jaxify json.name
      text.replaceWith "<div class='tex'><script id='tex-#{json.id}' type='math/tex'>#{jaxified}</script></div>"
      # kinda imp. to wrap <script> within some <div>
      j = obj.find('script')[0]
      text = $(j).parent()
      MathJax.Hub.Queue ['Typeset', MathJax.Hub, j]
    else
      text.text json.name

    obj.attr 'marker', json.id
    for a in obj.find("input[type='checkbox']") # either an immediate child or one inside a button
      $(a).attr 'name', "checked[#{json.id}]"
      $(a).attr 'id', "checked_#{json.id}"

    subtext = obj.children(".subtext").eq(0)
    if subtext.length > 0
      # If JSON has :tag 
      if json.tag?
        $(m).remove() for m in obj.children('button')
        subtext.text json.tag
        unless mn
          spanLeft -=3
          subtext.removeClass 'span2'
          subtext.addClass 'span3'
        else
          spanLeft -= 2
      else
        subtext.remove()

    # .text is always used
    text.addClass "span#{spanLeft}"

    # Append the cloned and edited obj
    obj.appendTo here
    return true
}

### 
  All lines 
###


window.lines = {
  columnify : (here, json, childKey, menu, buttons = null) ->
    # json = array of N objects 
    here = if typeof here is 'string' then $(here) else here
    columns = here.find '.column'
    nColumns = columns.length
    perColumn = if nColumns > 0 then ((json.length / nColumns ) + 1) else json.length

    currIndex = 0
    currColumn = if nColumns > 0 then columns.eq(currIndex) else here
    nAdded = 0

    for m,j in json
      if nAdded > perColumn
        currIndex += 1
        currColumn = columns.eq(currIndex)
        nAdded = 0
      line.write currColumn, m[childKey], menu, buttons
      nAdded += 1
    return true

}
