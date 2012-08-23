
###
  Customize the swiss-knife 
###

window.swissKnife = {

  ###
    The function below assumes that the passed JSON structure has at least
    the following 2 keys : name & id. The other keys handled here are 'checked'
    and 'selected'

    record = { key : { id: abc, name: stu, ticker: ... } }
    JSON = [ record_1, record_2 .... ]
  ###
  forge : (record, key, visible = {radio:true}, ticker = null, enable = true) ->
    clone = $('#toolbox').children('.blueprint.swiss-knife').first().clone()
    swissKnife.customize clone, visible, enable

    data = record[key]
    id = data.id
    clone.attr 'marker', id

    for child in clone.children()
      marker = $(child).attr 'marker'
      name = $(child).attr 'name'

      if marker? then $(child).attr 'marker', id
      if name?
        x = $(child).attr('name').replace('tbd', "#{id}")
        $(child).attr 'name', x

      if $(child).hasClass 'label' then $(child).text(data.name)
      switch $(child).attr 'type'
        when 'checkbox'
          $(child).prop 'checked', (if data.checked isnt null then data.checked else false)
        when 'select'
          $(child).val data.select

      if ticker? and $(child).hasClass 'micro-ticker'
        v = data[ticker]
        $(child).text v if v?

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

    for key in ['label', 'radio', 'checkbox', 'select', 'button', 'link']
      # retain = (key is 'label') or (visible[key]? and visible[key] is true)
      if key isnt 'label'
        retain = (visible[key]? and visible[key] is true)
      else
        retain = (not visible[key]? or visible[key] is true)

      thing = element.find ".#{key}:first"
      #if not(visible[key]?) or (visible[key] is false)
      if retain is false
        thing.remove()
        # thing.addClass 'hidden'
        # thing.prop 'disabled', true # hidden elements get no choice
      else
        thing.removeClass 'hidden'
        thing.prop 'disabled', not enable
    return true

  editAnchor: (element, json) ->
    # json has the following keys: 
    #   mandatory: name, id
    #   optional:  parent and parent_id
    return false if not element.hasClass 'swiss-knife'
    a = element.children('a').eq(0)
    a.attr 'marker', json.id
    a.attr 'parent', json.parent if json.parent?
    a.attr 'p_id', json.parent_id if json.parent_id?
    a.text json.name
    return true

  ###
    Sets new option values for <select> within a swiss-knife
  ###
  rebuildSelect: (e, name, values=[], text=[]) ->
    # 1-to-1 mapping b/w values & text
    return false if not e.hasClass 'swiss-knife'
    s = e.children('select').eq(0)
    return false if not s?
    s.empty() # empty out any old options 
    id = e.attr 'marker'
    s.attr 'name', "#{name}[#{id}]"

    tl = text.length
    for v,j in values
      t = if j < tl then text[j] else v
      $("<option value=#{v}>#{t}</option>").appendTo s
    return true

  ###
    Customize all swiss-knives within passed hierarchy
  ###
  customizeWithin : (element, visible = { radio:true }, enable = false) ->
    element = if typeof element is 'string' then $(element) else element

    for e in element.find '.swiss-knife'
      swissKnife.customize $(e),visible,enable
    return true

  setButtonCaption : (within, caption) ->
    return if not caption?
    within = if typeof within is 'string' then $(within) else within
    for button in within.find '.swiss-knife > input[type="button"]'
      continue if $(button).hasClass 'hidden'
      $(button).val caption
    return true

  setJsonAsAttribute: (json, within, key, which, setOn = { button: true} ) ->
    here = if typeof within is 'string' then $(within) else within

    buttons = here.find 'input[type="button"]'
    radios = here.find 'input[type="radio"]'
    checks = here.find 'input[type="checkbox"]'
    selects = here.find 'select'

    for d, index in json
      e = d[key]
      value = e[which]

      if setOn.button then buttons.eq(index).attr "#{which}", value
      if setOn.radio then radios.eq(index).attr "#{which}", value
      if setOn.checkbox then checkboxes.eq(index).attr "#{which}", value
      if setOn.select then selects.eq(index).attr "#{which}", value

    return true

}

