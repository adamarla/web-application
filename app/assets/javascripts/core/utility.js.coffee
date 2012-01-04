
putBack = (node) ->
  node = node.detach()
  node.appendTo '#toolbox'

buildHierarchy = (selector) ->
  needed = selector.split ' >'
  start = $(needed[0])
  length = start.length

  if length is 0 then return null
  else
    #alert "#{length} -> #{start.attr 'id'}"
    for j in [0 ... length]
      current = $(needed[j])
      next = $(needed[j+1])

      if not (current.length is 0 or next.length is 0)
        #alert "#{current.attr 'id'} --> #{next.attr 'id'}"
        next = next.detach()
        next.appendTo current
  return start

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

resetPanel = (id, moveAlso = true) ->
  start = if typeof id is 'string' then $(id) else id

  me = id.children().first()
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


window.refreshView = (link) ->
  link = if typeof link is 'string' then $(link) else link

  for type in ['side', 'middle', 'right', 'wide']
    needed = link.attr type
    target = $("##{type}-panel")

    continue if link.hasClass('minor-link') and type is 'side'
    resetPanel target # if there is any data to be purged, then it should be done before the next step
    continue if target.find(needed).length isnt 0

    if not needed?
      $(target).addClass('hidden')
    else
      e = buildHierarchy needed
      $(target).removeClass('hidden')
      if e isnt null then e.appendTo(target).hide().fadeIn('slow')
  return true

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
    if marker?
      value = data[marker]
      $(input).val value
      if $(input).attr('type') is 'checkbox' then $(input).prop 'checked', value

window.clearForm = (form) ->
  form = if typeof form is 'string' then $(form) else form
  for input in form.find 'input,textarea,select'
    $(input).val null
    if $(input).attr('type') is 'checkbox' then $(input).prop 'checked', false

window.uncheckAllCheckBoxesWithin = (element) ->
  element = if typeof element is 'string' then $(element) else element
  for checkbox in element.find 'input[type="checkbox"]'
    $(checkbox).prop 'checked', false

window.displayJson = (json, where, key, visible = {radio:true}, enable = true) ->
  # JSON data is always purgeable. And so, it is always inserted within
  # the first .purgeable of $(where)
  where = if typeof where is 'string' then $(where) else where
  target = if where.length isnt 0 then where.children('.purgeable:first') else null

  return if target is null
  target.empty() # Purge before showing new data

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

