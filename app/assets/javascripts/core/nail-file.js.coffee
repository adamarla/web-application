
window.nailFile = {
  customize : (element, json, visibility = {anchor : true, button:false}) ->
    element.removeClass 'blueprint'
    element.attr 'marker', "#{json.id}"

    anchor = element.children('a:first')
    anchor.attr 'marker', "#{json.id}"
    anchor.text "#{json.name}"

    if visibility.anchor is true
      anchor.removeClass 'hidden'
      anchor.prop 'disabled', false
    else
      anchor.addClass 'hidden'
      anchor.prop 'disabled', true

    btn = element.children 'input[type="button"]:first'
    if visibility.button is true
      btn.attr 'marker', "#{json.id}"
      btn.prop 'disabled', false
      btn.removeClass 'hidden'
    else
      btn.prop 'disabled', true
      btn.addClass 'hidden'

    return true
}
