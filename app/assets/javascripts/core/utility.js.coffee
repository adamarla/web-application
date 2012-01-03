
putBack = (node) ->
  node = node.detach()
  node.appendTo '#toolbox'

###
When clearing panels, only one of the following 4 can be done to
the elements within the said panel :
  1. the element's internals can be purged
  2. the element can be moved back to #toolbox
  3. both (1) and (2)
  4. neither (1) nor (2)
      
These 4 possibilities can be captured using just 2 class attributes -
purgeable and put-back. The former has been around for some time
while the latter is being introduced with the benefit of hindsight 
###

window.clearPanel = (id, moveAlso = true) ->
  me = $(id).children().first()
  return if me.length is 0
   ###
     If 'me' has any data under a <div class="data empty-on-putback"> within its
     hierarchy, then empty that data first. Note, that it is assumed that
     the emptied out data can re-got from an AJAX query. In other words,
     if some data is too valuable to lose, then *do not* put it under
     .purgeable.empty-on-putback
   ###
  for node in me.find '.purgeable'
    $(node).empty()
  for node in me.find '.put-back' # children that need to be put back separately
    putBack $(node)

  putBack me if moveAlso is true
  return true


window.refreshView = (linkId) ->
  link = $('#' + linkId)

  for type in ['side', 'middle', 'right', 'wide']
    needed = link.attr type
    target = "##{type}-panel"

    continue if link.hasClass('minor-link') and type is 'side'
    loaded = $(target).children().first()
    continue if loaded is $(needed)

    clearPanel target

    if not needed?
      $(target).addClass('hidden')
    else
      $(target).removeClass('hidden')
      $(needed).appendTo(target).hide().fadeIn('slow')

###
  Find the selected major or minor link in the #control-panel
###

window.findLastClickedLink = (type) ->
  if not type? then return null

  startPt = null
  switch type
    when 'minor'
      startPt = $('#minor-links')
    when 'major'
      startPt = $('#main-links')

  if startPt? then return startPt.find 'a[selected]:first' else return null

###
  Change the form's action as per passed URL 
###

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

window.uncheckAllCheckBoxesWithin = (element) ->
  element = if typeof element is 'string' then $(element) else element
  for checkbox in element.find 'input[type="checkbox"]'
    $(checkbox).prop 'checked', false

window.displayJson = (json, where, key, visible = {radio:true}, enable = true) ->
  target = if $(where).hasClass 'data' then $(where) else $(where).find('.purgeable:first')
  if target.length is 0 then target = $(where)

  for record, index in json
    clone = swissKnifeForge record, key, visible, enable
    clone.appendTo(target).hide().fadeIn('slow')

###
  The next function will create <options> for any <selects> within the passed 
  object. The function is agnostic to who, why and how the <select>s were created
###

window.populateSelectsWithOptions = (obj, selections) ->
  ###
    'selections' is of the form { 1:{ 1:<string>, 2:<string> .. }, 2:{ 1:<string> ...} }
    The outer keys specify which n-th <select> to update
    The inner-hash specifies the <option>s that need to be set
    the n-th <select>

    This function sets some limits on the # of <select>s within a hierarchy (10)
    and the number of options within each <select> (15). I think these should be 
    enough for most cases
  ###
  return if not obj?

  selects = for nth,options of selections
    select = obj.find('select').eq(nth)
    break if select.length is 0

    select.prop 'disabled', false
    choices = for posn,choice of options
      select.append "<option value=#{posn}>#{choice}</option>"
  return true

