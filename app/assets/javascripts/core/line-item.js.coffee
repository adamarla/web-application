
window.line = {
  write : (here, json, menu) ->
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
    
    # If JSON has :badge 
    b = obj.find('.badge').eq(0)
    if (json.badge? or not json.long?)
      if json.badge?
        b.text json.badge
      else
        b.removeClass 'span1'
      spanLeft -= (if mn then 1 else 2)
      b.addClass 'offset1' unless mn
      b.next().remove() # long-badge
      bdg = true
    else if json.long?
      b = obj.find('.long-badge').eq(0)
      b.text json.long
      spanLeft -= (if mn then 2 else 3)
      b.addClass 'offset1' unless mn
      b.prev().remove() # badge 
      lngBdg = true

    # Write contents of JSON 
    text = obj.find('.text').eq(0)

    if json.name.search(/\$.*\$/) isnt -1
      jaxified = karo.jaxify json.name
      text.replaceWith "<script id='tex-#{json.id}' type='math/tex'>#{jaxified}</script>"
      j = obj.find('script')[0]
      text = $(j)
      MathJax.Hub.Queue ['Typeset', MathJax.Hub, j]
    else
      text.text json.name
    obj.attr 'marker', json.id
    for a in obj.find("input[type='checkbox']")
      $(a).attr 'name', "checked[#{json.id}]"
      $(a).attr 'id', "checked_#{json.id}"

    subtext = obj.find('.subtext').eq(0)

    # If JSON has :tag 
    if json.tag?
      subtext.text json.tag
      unless mn
        spanLeft -=3
        subtext.removeClass 'span2'
        subtext.addClass 'span3'
      else
        spanLeft -= 2
    else
      subtext.remove()
    textRow = text.parent()
    textRow.removeClass 'span'
    textRow.addClass "span#{spanLeft}"

    # Append the cloned and edited obj
    obj.appendTo here
    return true
}

