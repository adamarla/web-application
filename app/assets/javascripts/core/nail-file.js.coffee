
window.nailFile = {
  customize : (element, json, anchor = true, buttons = []) ->
    element.removeClass 'blueprint'
    element.attr 'marker', "#{json.id}"

    if anchor is true
      a = element.children('a:first')
      a.removeClass 'hidden'
      a.attr 'marker', "#{json.id}"
      a.text "#{json.name}"

    for btn,index in buttons
      b = element.children('input[type="button"]').eq(index)
      break if b.length is 0
      b.removeClass 'hidden'
      b.addClass "#{buttons[index]}"
      b.prop 'disabled', false
      b.val buttons[index]
      b.attr 'marker', "#{json.id}"
    return true

}
