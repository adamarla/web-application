
window.adminUtil = {

  buildSyllabiEditForm : (json) ->
    # 1. Move #micro-selected-list to within #edit-syllabi-form
    target = $('#edit-syllabi-form > form:first')
    selected = $('#micro-selected-list').detach()
    selected.appendTo target
    
    # 2. Customize swiss-knives to have only the <select> visible & enabled
    swissKnife.customizeWithin selected, {select:true}, true

    # 3. Load the difficulty levels for micro-topics using the passed JSON
    #    JSON is of the form : [{macro : { .., micros : { ... } }}, { macro : { .., micros : { ... } }}]

    for a in json
      macro = a.macro
      continue if not macro.in is true # don't waste time w/ these

      micros = macro.micros
      start = selected.children "div[marker=#{macro.id}]:first"
      start.addClass 'hidden'

      for b in micros
        micro = b.micro
        select = start.children("div[marker=#{micro.id}]:first").children("select:first")
        select.val micro.select
    return true

  mnmToggle : (type, id, customization = null) ->
    ### 
      type = 'selected' OR 'deselected', id = of the macro
      If 'type' = selected, then we are moving a 'selected' element 
      to the 'deselected' list. Otherwise, the other way round
    ###

    other = if type is 'selected' then 'deselected' else 'selected'

    source = $("#micro-#{type}-list").children("div[marker=#{id}]").detach()
    target = $("#micro-#{other}-list")
    source.appendTo target

    if type is 'selected'
      swissKnife.customizeWithin source, {}, false
    else
      source.addClass 'hidden'
      swissKnife.customizeWithin source, customization, true
}

###
  Given the JSON response of 'questions/list.json', populates #document-preview
  for use by Popeye plugin
###

window.prepareTBDSlideShow = (json) ->
  baseUrl = "https://github.com/abhinavc/RiddlersVault/raw/master"
  target = $('#document-preview').find 'ul:first'

  # Empty the target to make space for a new list
  target.empty()

  for record in json
    question = record['question']
    relPath = question.name # actually, its the path. But in questions/list.rabl, we override the key name
    folder = relPath.split('/').pop() # from X/Y/1_5, extract 1_5
    full = "#{baseUrl}/#{relPath}/#{folder}-answer.jpeg"
    thumb = "#{baseUrl}/#{relPath}/#{folder}-thumb.jpeg"

    preview = $("<li><a href=#{full}><img src=#{thumb} alt=#{folder}/></a></li>")
    preview.appendTo target

  ###
    If popeye() was called once before, then don't call it again on #document-preview.
    If you do, then the border around the preview will get thicker and thicker.
    Other weird stuff can happen too
  ###

  ppy = $('#document-preview').closest '.ppy-placeholder'
  if ppy.length is 0
    $('#document-preview').popeye()
  
