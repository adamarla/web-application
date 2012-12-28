
window.line = {
  write : (here, json, menu) ->
    here = if typeof here is 'string' then $(here) else here
    ###
      Passed JSON is assumed to have atleast the following keys
        name: written as the first line 
        id: set as 'marker' attribute 
        tag (optional): written as the second line in a .two-line - if provided
    ###
    # type = if json.tag? then '.two-line' else ''

    obj = $('#toolbox').children('.single-line').eq(0).clone()
    spanLeft = 11

    # Write contents of JSON 
    obj.find('.text').eq(0).children().eq(0).text json.name
    obj.attr 'marker', json.id
    for a in obj.find("input[type='checkbox']")
      $(a).attr 'name', "checked[#{json.id}]"
      $(a).attr 'id', "checked_#{json.id}"

    subtext = obj.find('.subtext').eq(0)
    text = subtext.prev()

    # If JSON has :tag 
    if json.tag?
      subtext.children().eq(0).text json.tag
      subtext.addClass 'span3'
      spanLeft -= 3
      # text.addClass 'span8'
    else
      # text.addClass 'span11'
      subtext.remove()
    
    # If JSON has :badge 
    b = obj.find('.badge').eq(0)
    if json.badge?
      b.text json.badge

    spanLeft -= 1

    b = obj.find('.long-badge').eq(0)
    if json.long?
      b.text json.long
      spanLeft -= 4
      b.parent().prev().remove() # .span1
      spanLeft += 1
    else
      b.parent().remove()

    text.addClass "span#{spanLeft}"

    # Set the menu(string) as an attribute on .dropdown > a - if provided
    toggle = obj.find('.dropdown-toggle')[0]
    dropDown = $(toggle).parent()
    textRow = dropDown.next()

    if menu?
      toggle.dataset.menu = menu
      dropDown.addClass 'span2'
      textRow.addClass 'span10'
    else
      dropDown.remove()
      textRow.addClass 'span12'

    # Append the cloned and edited obj
    obj.appendTo here
    return true
}

