
emptyMe = (node) -> $(node).empty()

putBack = (node) ->
  node = node.detach()
  node.appendTo '#toolbox'

clearPanel = (id, moveAlso = true) ->
  me = $(id).children().first()
  return if me.length is 0
   ###
     If 'me' has any data under a <div class="data empty-on-putback"> within its
     hierarchy, then empty that data first. Note, that it is assumed that
     the emptied out data can re-got from an AJAX query. In other words,
     if some data is too valuable to lose, then *do not* put it under
     .purgeable.empty-on-putback
   ###

  emptyMe node for node in me.find('.purgeable.empty-on-putback')
  putBack me if moveAlso is true


window.refreshView = (linkId) ->
  link = $('#' + linkId)

  for type in ['side', 'middle', 'right', 'wide']
    needed = link.attr type
    target = '#' + type + '-panel'

    continue if link.hasClass('minor-link') and type is 'side'
    loaded = $(target).children().first()
    continue if loaded is $(needed)

    clearPanel target

    if not needed?
      $(target).addClass('hidden')
    else
      $(target).removeClass('hidden')
      $(needed).appendTo(target).hide().fadeIn('slow')


window.resetRadioUrlsIn = (panel, url) ->
  for radio in $(panel).find 'input[type="radio"]'
    marker = $(radio).attr 'marker'
    continue if not marker? 

    if url?
      url = url.replace /id=\d*/g, "id=#{marker}"
    $(radio).attr 'url', url

window.resetRadioUrlsAsPer = (link) ->
  if link.hasClass('main-link') or link.hasClass('minor-link')
    for type in ['side', 'middle', 'right', 'wide']
      radioUrl = link.attr "#{type}-radio-url"
      panel = "##{type}-panel"
      resetRadioUrlsIn panel, radioUrl

window.editFormAction = (formId, url, method = 'post') ->
  form = $(formId).find 'form:first'
  if form.length is 1
    form.attr 'action', url
    form.attr 'method', method

fillValue = (value, field) ->
  field.val value
  field.prop 'checked', value if field.attr 'type' is 'checkbox'

window.loadFormWithJsonData = (form, data) ->
  ###
   This function assumes that the JSON data is flat - that is, it has no nesting
   So, data = { x:a, y:b .. } is fine but data = { x:a, y: {z:d} .. } is not
   Also, note that in each formtastic form this function is called on, we have
   added a 'marker' attribute = DB field-name for each input. The input field gets
   value = data[marker] if it has a marker
  ###
  form = if typeof form is 'string' then $(form) else form

  for input in form.find 'input[marker],textarea[marker],select[marker]'
    marker = $(input).attr 'marker'
    fillValue data[marker], $(input) if (data[marker] isnt null and marker isnt null)

window.clearAllFieldsInForm = (form) ->
  fillValue '', input for input in form.find 'input,select,textarea'

setBooleanPropOn = (node, prop, value = false) ->
  $(node).prop prop, value

window.uncheckAllCheckBoxesWithin = (element) ->
  element = if typeof element is 'string' then $(element) else element
  setBooleanPropOn checkbox, 'checked', false for checkbox in element.find 'input[type="checkbox"]'

window.uncheckAllRadioButtonsWithin = (element) ->
  element = if typeof element is 'string' then $(element) else element
  setBooleanPropOn radio, 'checked', false for radio in element.find 'input[type="radio"]'

window.disableAllSelectsWithin = (element) ->
  element = if typeof element is 'string' then $(element) else element
  setBooleanPropOn select, 'disabled', true for select in element.find 'select'


###
  Customize the God-element 
###

window.customizeGodElement = (element, options = { radio:true, checkbox:true, select:false, button:false }) ->
  element = if typeof element is 'string' then $(element) else element
  return if not element.hasClass 'god-element'

  for key in ['radio', 'checkbox', 'select', 'button']
    thing = element.find ".#{key}:first"
    thing.prop 'disabled', true
    if not(options[key]?) or (options[key] is false)
      thing.addClass 'hidden'
    else
      thing.removeClass 'hidden'

###
  This function assumes that for whichever model the returned json is responds to
  the following 2 methods : name and id
###


window.selectionWithRadio = (json, key) ->
  data = json[key]
  clone = $('#toolbox .radio-column:first').clone()
  radio = clone.children '.radio:first'
  label = clone.children '.label:first'

  label.text data['name']
  radio.attr 'marker', data['id']
  setBooleanPropOn radio,'checked', false
  if url?
    url = url + '.json?id=' + data['id']
    radio.attr 'url', url
  return clone

window.selectionWithCheckbox = (json, key, name = 'checked') ->
  data = json[key]
  clone = $('#toolbox .checkbox-column:first').clone()
  checkBox = clone.children '.checkbox:first'
  label = clone.children '.label:first'

  label.text data['name']
  checkBox.attr 'marker', data['id']
  checkBox.attr 'name', "#{name}[#{data['id']}]"
  setBooleanPropOn checkBox, 'checked', data['checked']
  return clone

buildLineItem = (json,key) ->
  data = json[key]
  clone = $('#toolbox .line-item:first').clone()
  label = clone.children '.label:first'

  label.text data['name']
  return clone

###
  This next function assumes that the returned JSON has at least the 
  following 3 keys : name, id and select. If 'select' is null, then 
  the <select> menu is disabled and the sibling check-box un-checked
###

window.cboxLabelSelect = (json, key, name = 'checked') ->
  data = json[key]
  clone = $('#toolbox .cbox-label-select:first').clone()
  cbox = clone.children '.checkbox:first'
  label = clone.children '.label:first'
  menu = clone.find 'select:first'
  
  label.text data.name
  cbox.attr 'marker', data.id
  cbox.attr 'name', "#{name}[#{data.id}]"
  selected = data.select

  if selected isnt null
    menu.prop 'disabled', false
    menu.val selected
    cbox.prop 'checked', true
  else
    menu.prop 'disabled', true
    cbox.prop 'checked', false

  menu.attr 'name', "syllabi[#{data.id}]" # Change to more generic behaviour later !!
  return clone
  

window.displayJson = (json, where, key, withRadio = true, withCheck = false, withSelect = false) ->
  target = if $(where).hasClass 'data' then $(where) else $(where).find('.purgeable:first')
  if target.length is 0 then target = $(where)

  for record, index in json
    if withRadio is true
      clone = selectionWithRadio record,key
    else if withCheck is true
      if withSelect is true
        clone = cboxLabelSelect record, key
      else
        clone = selectionWithCheckbox record,key

    clone.addClass 'colored' if index % 2 is 1
    clone.appendTo(target).hide().fadeIn('slow')

