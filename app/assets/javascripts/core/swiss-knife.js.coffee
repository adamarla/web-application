
###
  Customize the swiss-knife 
###

window.swissKnifeCustomize = (element, visible = { radio:true, checkbox:false, select:false, button:false }, enable = false) ->
  element = if typeof element is 'string' then $(element) else element
  return false if not element.hasClass 'swiss-knife'

  for key in ['radio', 'checkbox', 'select', 'button']
    thing = element.find ".#{key}:first"
    if not(visible[key]?) or (visible[key] is false)
      thing.addClass 'hidden'
      thing.prop 'disabled', true # hidden elements get no choice
    else
      thing.removeClass 'hidden'
      thing.prop 'disabled', not enable
  return true

###
  Reset swiss-knife to a virginal state. This means : 
    1. Hide & disable everything other than the label
    2. Set value = 0 on <select>
    3. Uncheck all radio-buttons and check-boxes
###

window.swissKnifeReset = (element) ->
  return false if not swissKnifeCustomize(element) # (1)

  select = element.children 'select:first'
  select.val 0 # (2)

  for active in element.children 'input[type="checkbox"], input[type="radio"]'
    $(active).prop 'checked', false

###
  The function below assumes that the passed JSON structure has at least
  the following 2 keys : name & id. The other keys handled here are 'checked'
  and 'selected'
###

window.swissKnifeForge = (record, key, visible = {radio:true}, enable = true) ->
  clone = $('#toolbox .swiss-knife:first').clone()
  swissKnifeCustomize clone, visible, enable

  data = record[key]
  label = clone.children '.label:first'
  label.text data.name

  for other in ['radio', 'checkbox', 'select', 'button']
    e = clone.children ".#{other}:first"
    continue if e.hasClass 'hidden'
    if other is 'radio' or other is 'checkbox'
      e.prop 'checked', (if data.checked isnt null then data.checked else false)
      e.attr 'marker', data.id
    else if other is 'select'
      e.val data.select
  return clone
  
