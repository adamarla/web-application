
window.adminUtil = {

  buildSyllabiEditForm : (json) ->
    # 1. Move #topic-selected-list to within #edit-syllabi-form
    target = $('#edit-syllabi-form > form:first')
    selected = $('#topic-selected-list').detach()
    selected.appendTo target
    
    # 2. Customize swiss-knives to have only the <select> visible & enabled
    swissKnife.customizeWithin selected, {select:true}, true

    # 3. Load the difficulty levels for topics using the passed JSON
    #    JSON is of the form : [{vertical : { .., topics : { ... } }}, { vertical : { .., topics : { ... } }}]

    for a in json
      vertical = a.vertical
      continue if not vertical.in is true # don't waste time w/ these

      topics = vertical.topics
      start = selected.children "div[marker=#{vertical.id}]:first"
      start.addClass 'hidden'

      for b in topics
        topic = b.topic
        select = start.children("div[marker=#{topic.id}]:first").children("select:first")
        select.val topic.select
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

  buildPendingScanList: (json) ->
    here = $('#list-pending')
    here.empty() # purge any old lists
    for item in json
      e = $("<div scan=#{item.scan}/>")
      for id, index in item.indices
        questionLabel = item.labels[index]

        if item.mcq[index] is true
          $("<div response_id=#{id} mcq='true' qLabel=#{questionLabel}/>").appendTo(e)
        else
          $("<div response_id=#{id} qLabel=#{questionLabel}/>").appendTo(e)
      e.appendTo here
    nImages = here.children('div[scan]').length
    here.attr 'length', nImages
    here.attr 'current', 0
    return true

}
