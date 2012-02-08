
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

idInMacroJson = (id, json) ->
  return json if typeof json is 'boolean'
  selected = false
  for record in json
    data = record.macro
    selected = (data.id is id) and (data.in is true)
    break if selected is true
  return selected
  

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

###
  Display inline-error messages 
###

###
  The list of macro and micro topics is known at the time of HTML rendering - 
  and is therefore statically rendered within the 2 master-lists : 
  macro-masterlist and micro-masterlist 

  However, depending on the context, some macro-topics - and as a result, some 
  micro-topics - are "applicable" while others are not. And the ones that are 
  "applicable" we want in one list while those that aren't we want in another. 
  This next set of functions manages that required sorting 

  Once again, note that what is "applicable" and what is not depends really on 
  the what the question is. The answer comes in the form of a JSON response 
  with AT LEAST the following structure : 

     { macros : [ {macro : {id, [in]}}, { macro : {id, [in] }}, ... ] }

  The keys HAVE TO BE as shown. And conversely, if you want to use the functions
  below, you will have to structure the JSON response as shown. The [in] key is an optional
  boolean. But its always interpreted as follows : 
    1. macro-topic - and resulting micro-topics - are "applicable" if in=true
       and "not applicable" if in=anyting else
###

window.coreUtil = {

  # Namespace for functions related to macro and micro lists
  mnmlists : {

    attach : (type, here) -> # type = [macro,micro]
      return if not type? and not here?
      here = if typeof here is 'string' then $(here) else here
      source = $("##{type}-selected-list").detach()
      source.appendTo here
      return true

    asAccordion : (type = 'selected') -> # type = [selected, deselected]
      macros = $("#macro-#{type}-list")
      micros = $("#micro-#{type}-list")
      accordion = $('<div class="as-accordion" />')

      for macro in macros.children()
        id = $(macro).attr 'marker'

        header = $(macro).clone()
        header.addClass 'accordion-heading'

        content = micros.children("[marker=#{id}]:first").clone()
        content.removeClass 'hidden'
        content.addClass 'accordion-content'

        header.appendTo accordion
        content.appendTo accordion

      return accordion

    restore : () ->
      for type in ['macro', 'micro']
        master = $("##{type}-masterlist") # Eg. macro-masterlist
        for j in ['selected', 'deselected']
          source = $("##{type}-#{j}-list") # Eg. micro-selected-list
          for child in source.children()
            child = $(child).detach()
            child.appendTo master
      return true

    customize : (type = 'macro', visible = {radio:true}) ->
      for x in ['selected','deselected']
        target = $("##{type}-#{x}-list") # Eg. #macro-selected-list
        enable = if x is 'selected' then true else false
        swissKnife.customizeWithin target, visible, enable
      return true

    redistribute : (json) ->
      # Cool trick : If you know that everything is to go in the 
      # selected(deselected) list, then simply pass json = true(false)

      # That said, first bring everything back into macro & micro master lists
      coreUtil.mnmlists.restore()

      # Now, based on the JSON, sort into selected and deselected lists
      macroS = $('#macro-selected-list')
      macroU = $('#macro-deselected-list')
      microS = $('#micro-selected-list')
      microU = $('#micro-deselected-list')

      for macro in $('#macro-masterlist').children()
        id = $(macro).attr 'marker'
        selected = idInMacroJson parseInt(id), json
        micro = $('#micro-masterlist').children("[marker=#{id}]").first()

        if selected
          macroS.append $(macro).detach()
          microS.append micro.detach()
        else
          macroU.append $(macro).detach()
          microU.append micro.detach()
      return true

  } # end of namespace 'mnmlists'
  
  # Namespace for functions impacting the interface
  interface : {
    refreshView : (link) ->
      link = if typeof link is 'string' then $(link) else link

      for type in ['side', 'middle', 'right', 'wide']
        needed = link.attr type
        target = $("##{type}-panel")

        if not needed?
          continue if link.hasClass('minor-link') and type is 'side'
          target.addClass 'hidden'
          resetPanel target
        else
          continue if target.find(needed).length isnt 0 # already present
          resetPanel target
          e = buildHierarchy needed
          $(target).removeClass('hidden')
          if e isnt null then e.appendTo(target).hide().fadeIn('slow')
      return true

    ###
      Parse and then display the returned JSON. The function below assumes - 
      via swissKnife.forge - that the returned JSON has atleast the following 
      2 keys : name & id
    ###
    displayJson : (json, where, key, visible = {radio:true}, enable = true) ->
      # JSON data is always purgeable. And so, it is always inserted within
      # the first .purgeable of $(where)
      where = if typeof where is 'string' then $(where) else where
      target = where.find '.purgeable:first'
      target = if target.length is 0 then where else target

      return if target is null
      target.empty() # Purge before showing new data

      for record, index in json
        clone = swissKnife.forge record, key, visible, enable
        clone.appendTo(target).hide().fadeIn('slow')
      return true

    # Find the selected major or minor link in the #control-panel
    lastClicked : (type) ->
      if not type? then return null
      startPt = null
      switch type
        when 'minor'
          startPt = $('#minor-links')
        when 'major'
          startPt = $('#main-links')
      if startPt? then return startPt.find 'a[selected]:first' else return null

  } # end of namespace 'interface'

  # Namespace for functions pertaining to forms 
  forms : {

    clear : (form) ->
      form = if typeof form is 'string' then $(form) else form
      for input in form.find 'input:not([type="submit"]),textarea,select'
        $(input).val null
        if $(input).attr('type') is 'checkbox' then $(input).prop 'checked', false
      return true

    # Change the form's action as per passed URL 
    modifyAction : (formId, url, method = 'post') ->
      form = if typeof formId is 'string' then $(formId).find('form:first') else formId
      if form.length is 1
        form.attr 'action', url
        form.attr 'method', method
      return true

    loadJson : (form, data) ->
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
      return true

    checkAllIn : (form, state = true) ->
      ###
        This functions checks/unchecks all visible checkboxes in swiss-knives 
        within the passed form
      ###
      form = if typeof form is 'string' then $(form) else form
      for knife in form.find '.swiss-knife'
        check = $(knife).children 'input[type="checkbox"]:first'
        continue if check.hasClass 'hidden'
        check.prop 'checked', state
      return true

  } # end of namespace 'forms'

  dom : {
    unsetCheckboxesIn : (element) ->
      element = if typeof element is 'string' then $(element) else element
      for checkbox in element.find 'input[type="checkbox"]'
        $(checkbox).prop 'checked', false
      return true

    ###
      The next function will create <options> for any <selects> within the passed 
      object. The function is agnostic to who, why and how the <select>s were created
    ###

    buildSelectOptions : (obj, selections) ->
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

    ###
      This method creates <option>s based on the passed JSON for the passed <select>
      It assumes that the JSON has the following 2 keys : id & name
    ###
    loadJsonToSelect : (select, json, key) ->
      return if not key? or not select?
      # Purge any previous <option> entries 
      select.empty()
      for record in json
        data = record[key]
        select.append "<option value=#{data.id}>#{data.name}</option>"
      return true

  } # end of namespace 'dom'

  messaging : {
    inlineError : (here, heading, description) ->
      here = if typeof here is 'string' then $(where) else here
      clone = $('#toolbox').find('.blueprint.inline-error:first').clone()

      head = clone.children().eq(0)
      desc = clone.children().eq(1)

      head.text heading
      desc.text description

      clone.appendTo(here).hide().fadeIn('slow')
      return true
  } # end of namespace 'messaging'

  accordion : {
    build : (json, firstIter, secondHandle, secondIter, sharedBtns = []) ->
      ### 
      Example :
        json = quizzes
        parent = json.quiz
        family = json.quiz.testpapers
        child = json.quiz.testpapers.testpaper
      ###

      accordion = $("<div class='as-accordion'/>")

      for parentList in json
        parent = parentList[firstIter]
        family = parent[secondHandle]
        continue if not parent.id?

        ###
          Generally speaking, give preference to a randomized_id - if available -
          over plain id
        ###
        id = if parent.randomized_id? then parent.randomized_id else parent.id

        heading = $("<div class='accordion-heading' marker=#{id}>#{parent.name}</div>")
        heading.appendTo accordion
        content = $("<div class='accordion-content'/>")
        content.appendTo accordion

        # Quiz-specific links - shared by all 
        shared = $('#toolbox > .nail-file:first').clone()
        nailFile.customize shared, parent, sharedBtns
        shared.appendTo content

        for children in family
          child = children[secondIter]
          item = $('#toolbox > .nail-file:first').clone()
          nailFile.customize item, child, ['test-download'], parent
          item.appendTo content
          #alert "#{child.id} ---> #{parent.id}"

      return accordion
  }

} # end of namespace 'coreUtil'

