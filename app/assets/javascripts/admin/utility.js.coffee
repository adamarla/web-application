
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
