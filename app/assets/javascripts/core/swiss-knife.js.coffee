
###
  Customize the swiss-knife 
###

window.swissKnife = {

  ###
    The function below assumes that the passed JSON structure has at least
    the following 2 keys : name & id. The other keys handled here are 'checked'
    and 'selected'
  ###
  forge : (record, key, visible = {radio:true}, enable = true) ->
    clone = $('#toolbox').children('.blueprint.swiss-knife').first().clone()
    swissKnife.customize clone, visible, enable

    data = record[key]
    id = data.id
    clone.attr 'marker', id

    for child in clone.children()
      if $(child).hasClass 'hidden'
        continue unless $(child).hasClass 'trojan'

      marker = $(child).attr 'marker'
      name = $(child).attr 'name'

      if marker? then $(child).attr 'marker', id
      if name?
        x = $(child).attr('name').replace('tbd', "#{id}")
        $(child).attr 'name', x

      if $(child).hasClass 'label' then $(child).text(data.name)
      switch $(child).attr 'type'
        when 'radio', 'checkbox'
          $(child).prop 'checked', (if data.checked isnt null then data.checked else false)
        when 'select'
          $(child).val data.select
    return clone

  ###  
    Reset swiss-knife to a virginal state. This means : 
      1. Hide & disable everything other than the label
      2. Set value = 0 on <select>
      3. Uncheck all radio-buttons and check-boxes
  ###
  reset : (element) ->
    return false if not swissKnife.customize(element) # (1)

    select = element.children 'select:first'
    select.val 0 # (2)

    for active in element.children 'input[type="checkbox"], input[type="radio"]'
      $(active).prop 'checked', false

  ###
    Customize a single swiss-knife as per passed parameters
  ###
  customize : (element, visible = { radio:true }, enable = false) ->
    element = if typeof element is 'string' then $(element) else element
    return false if not element.hasClass 'swiss-knife'

    element.removeClass 'blueprint'

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
    Customize all swiss-knives within passed hierarchy
  ###
  customizeWithin : (element, visible = { radio:true }, enable = false) ->
    element = if typeof element is 'string' then $(element) else element

    for e in element.find '.swiss-knife'
      swissKnife.customize $(e),visible,enable
    return true
}

