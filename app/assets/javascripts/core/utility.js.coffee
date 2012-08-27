
putBack = (node) ->
  node = node.detach()
  node.appendTo '#toolbox'

idInVerticalJson = (id, json) ->
  return json if typeof json is 'boolean'
  selected = false
  for record in json
    data = record.vertical
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

resetPanel = (id) ->
  panel = if typeof id is 'string' then $(id) else id

  panel.attr 'marker', null

  for e in panel.find 'input[type="checkbox"], input[type="radio"]'
    $(e).prop 'checked', false
  return true

purge = (id) ->
  node = if typeof id is 'string' then $(id) else id
  for child in node.find '.purgeable'
    $(child).empty()
  return true

backInToolbox = (id) ->
  node = if typeof id is 'string' then $(id) else id

  for child in node.find '.put-back' # children that need to be put back separately
    putBack $(child)
  putBack node
  return true

window.coreUtil = {
  removeJQueryClasses: (obj) ->
    obj = if typeof obj is 'string' then $(obj) else obj
    classes = obj.attr 'class'
    obj.removeClass classes.match(/ui[\w\W]+/g) # space separated array of ui-* classes
    return true

  # Namespace for functions impacting the interface
  interface : {
    refreshView : (link) ->
      link = if typeof link is 'string' then $(link) else link

      for type in ['side', 'middle', 'right', 'wide']
        target = $("##{type}-panel")

        if type is 'side'
          resetPanel target if link.hasClass('main-link')
          side = link.attr 'side'
          continue if not side? or $("#{side}").length is 0
          # Rarely happens, but can happen. Examples: scan-loader-link(main)

        current = target.children().first()
        needed = $(link.attr type)

        purge target
        backInToolbox current unless current is needed
        if needed.length is 0
          target.addClass('hidden')
        else
          target.removeClass('hidden')
          needed.appendTo(target).hide().fadeIn('slow')
          #flipchart.rewind needed if needed.hasClass 'flipchart'

      return true

    ###
      Parse and then display the returned JSON. The function below assumes - 
      via swissKnife.forge - that the returned JSON has atleast the following 
      2 keys : name & id

      record = { key : { id: abc, name: stu, ticker: ... } }
      JSON = [ record_1, record_2 .... ]
    ###
    displayJson : (json, where, key, visible = {radio:true}, enable = true, ticker = 'ticker') ->
      # JSON data is always purgeable. And so, it is always inserted within
      # the first .purgeable of $(where)
      where = if typeof where is 'string' then $(where) else where
      target = where.find '.purgeable:first'
      target = if target.length is 0 then where else target

      return if target is null
      target.empty() # Purge before showing new data

      for record, index in json
        clone = swissKnife.forge record, key, visible, ticker, enable
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

    modalMsg : (title, paras = []) ->
      head = $('<div class="modal-msg"></div>')

      for p in paras
        $("<p>#{p}</p>").appendTo head

      head.dialog {
        modal: true,
        title: "#{title}",
        resizable: false,
        dialogClass: "alert"
      }
    
    loadGradeDetails: (json, here = '#understand-calibrations') ->
      ###
        This method assumes a JSON of the form: 
        { ..... weights: [insight,formulation,calculation] OR [mcq] ] ..... }

        HTML: $(here) > .equalizer > .level.left
      ###
      here = if typeof here is 'string' then $(here) else here
      root = if here.hasClass('calibrations') then here else here.children('.calibrations').eq(0)
      summary = root.children('.summary').eq(0)

      equalizers = summary.children '.equalizer'
      mcqMode = if json.weights.length is 3 then false else true
      colours = ['pinkoutline', 'pink', 'orange', 'green']

      # Remove any previously set classes: lightpink, pink,orange OR green from .level
      $(m).children('.level').eq(0).removeClass("pinkoutline pink orange green") for m in equalizers

      if mcqMode then root.attr('mcq','yes') else root.removeAttr('mcq')

      for m,j in json.weights
        m = parseInt(m)
        e = equalizers.eq(j)
        target = e.children('.level').eq(0)

        if j is 0
          label = e.children('.label').eq(0)
          if mcqMode then label.text("bottomline") else label.text("insight")

        # Calculations are ranked on a [0,2] scale - not [0,3] like the others
        onCalc = if j is 2 then true else false

        colour = -1
        switch m
          when 0
            colour = 0
          when 1
            colour = if onCalc then 2 else 1
          when 2
            colour = if onCalc then 3 else 2
          when 3
            colour = m

        # Apply the colour class
        target.addClass colours[colour] unless colour is -1
      return true

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
      return if not data?
      form = if typeof form is 'string' then $(form) else form

      for input in form.find 'input[marker],textarea[marker],select[marker]'
        marker = $(input).attr 'marker'
        if marker?
          value = (if data[marker]? then data[marker] else "")
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
        continue if $(knife).hasClass 'hidden'
        check = $(knife).children 'input[type="checkbox"]:first'
        check.prop 'checked', state unless check.hasClass 'hidden'
      return true

    numChecked : (form) ->
      ###
        Returns the number of checkboxes checked within the form. 
        The return value can be used to validate in case a min # of checkboxes
        need to be checked 
      ###
      form = if typeof form is 'string' then $(form) else form
      count = 0
      for m in form.find 'input[type="checkbox"]'
        count = count + 1 if $(m).prop('checked')
      return count

  } # end of namespace 'forms'

  dom : {
    unsetCheckboxesIn : (element) ->
      element = if typeof element is 'string' then $(element) else element
      for checkbox in element.find 'input[type="checkbox"]'
        $(checkbox).prop 'checked', false
      return true

    mkListFromJson : (json, here, key, ordered = false) ->
      # Assumes JSON has at least a key called 'name'
      here = if typeof here is 'string' then $(here) else here

      l = if ordered is true then $('<ol></ol>') else $('<ul></ul>')
      l.appendTo here

      for record in json
        data = record[key]
        l.append "<li>#{data.name}</li>"
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

        select.empty() # empty any previously added <option>
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

} # end of namespace 'coreUtil'

