
jQuery ->

  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    clickFirst = false # whether or not to auto-click the first .line
    lesson = null
    buttons = null

    if url.match(/course\/new/)
      $('#m-new-course').modal 'hide'
      return sngLine.write('#pane-courses', json)

    else if url.match(/teacher\/courses/)
      target = $('#pane-courses')
      key = 'courses'
      clickFirst = true

    else if url.match(/lessons\/list/) 
      target = $('#pane-my-lessons')
      key = 'lessons'

    else if url.match(/course\/quizzes/) || url.match(/course\/lessons/)
      return assetMgr.render(json)
      
    else if url.match(/ping\/course/)
      karo.tab.enable 'tab-course-overview'
    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst

    # If in tutorial mode, then start the next tutorial - if any
    tutorial.start lesson if lesson?

    e.stopPropagation() if matched is true
    return true
