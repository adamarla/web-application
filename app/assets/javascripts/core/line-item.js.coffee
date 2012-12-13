
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

    # Write contents of JSON 
    obj.find('.text').eq(0).children().eq(0).text json.name
    obj.attr 'marker', json.id

    subtext = obj.find('.subtext').eq(0)
    if json.tag?
      subtext.children().eq(0).text json.tag
    else
      text = subtext.prev()
      text.removeClass 'span9'
      text.addClass 'span11 offset1'
      subtext.remove()

    # Set the menu(string) as an attribute on .dropdown > a - if provided
    ddown = obj.find('.dropdown-toggle').eq(0)
    if menu?
      ddown.attr 'menu', menu
    else
      j = ddown.closest('.dropdown')
      row = j.next()
      row.removeClass 'span10'
      row.addClass 'span12'
      j.remove()

    # Append the cloned and edited obj
    obj.appendTo here
    return true
}

