
window.adminUtil = {

  buildSyllabiEditForm : (json) ->
    # 1. Move #topic-selected-list to within #edit-syllabi-form
    target = $('#edit-syllabi-form > form:first')
    selected = $('#topic-selected-list').detach()
    selected.appendTo target
    
    # 2. Customize swiss-knives to have only the <select> visible & enabled
    swissKnife.customizeWithin selected, {select:true}, true

    # 3. Load the difficulty levels for topics using the passed JSON
    #    JSON is of the form : [{vertical : { .., micros : { ... } }}, { vertical : { .., micros : { ... } }}]

    for a in json
      vertical = a.vertical
      continue if not vertical.in is true # don't waste time w/ these

      micros = vertical.micros
      start = selected.children "div[marker=#{vertical.id}]:first"
      start.addClass 'hidden'

      for b in micros
        micro = b.micro
        select = start.children("div[marker=#{micro.id}]:first").children("select:first")
        select.val micro.select
    return true

  mnmToggle : (type, id, customization = null) ->
    ### 
      type = 'selected' OR 'deselected', id = of the vertical
      If 'type' = selected, then we are moving a 'selected' element 
      to the 'deselected' list. Otherwise, the other way round
    ###

    other = if type is 'selected' then 'deselected' else 'selected'

    source = $("#topic-#{type}-list").children("div[marker=#{id}]").detach()
    target = $("#topic-#{other}-list")
    source.appendTo target

    if type is 'selected'
      swissKnife.customizeWithin source, {}, false
    else
      source.addClass 'hidden'
      swissKnife.customizeWithin source, customization, true
}
