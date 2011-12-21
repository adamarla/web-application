
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
     .data.empty-on-putback
   ###

  emptyMe node for node in me.find('.data.empty-on-putback')
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

setUrlOn = (radio, url) ->
  url = if url? then (url + radio.attr 'marker') else null
  radio.attr 'url', url

resetRadioUrlsIn = (panel, url) ->
  setUrlOn $(radio),url for radio in $(panel).find 'input[type="radio"]' when $(radio).attr('marker') isnt null

window.resetRadioUrlsAsPer = (link) ->
  if link.hasClass('main-link') or link.hasClass('minor-link')
    for type in ['side', 'middle', 'right', 'wide']
      radioUrl = link.attr "#{type}-radio-url"

      panel = '#' + type + '-panel'
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

  for input in form.find 'input,textarea,select'
    marker = input.attr 'marker'
    fillValue data[marker], input if (data[marker] isnt null and marker isnt null)

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
  This function assumes that for whichever model the returned json is responds to
  the following 2 methods : name and id
###


window.selectionWithRadio = (json, key) ->
  data = json[key]
  clone = $('#toolbox .radio-column:first').clone()
  radio = clone.children '.radio:first'
  label = clone.children '.content:first'

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
  label = clone.children '.content:first'

  label.text data['name']
  checkBox.attr 'marker', data['id']
  checkBox.attr 'name', "#{name}[#{data['id']}]"
  setBooleanPropOn checkBox, 'checked', data['checked']
  return clone

window.displayJson = (json, where, key, withRadio = true) ->
  where = if $(where).hasClass 'data' then $(where) else $(where).find('.data:first')
  for record, index in json
    clone = if withRadio then selectionWithRadio(record,key) else selectionWithCheckbox(record,key)
    clone.addClass 'colored' if index % 2 is 1
    clone.appendTo(where).hide().fadeIn('slow')

