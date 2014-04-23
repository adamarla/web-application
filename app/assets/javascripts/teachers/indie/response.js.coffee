
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
      return line.write('#pane-courses', json)

    else if url.match(/course\/all/)
      target = $('#pane-courses')
      key = 'courses'
      clickFirst = true

    else if url.match(/course\/quizzes/)
      return assetMgr.render(json)
      
    else if url.match(/milestone\/load/) || url.match(/available\/assets/)
      target = $('#lessons-and-quizzes')
      key = 'assets'
      menu = 'per-asset'

    else if url.match(/attach_detach_asset/)
      $('#mng-assets').modal 'hide'
    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst

    # If in tutorial mode, then start the next tutorial - if any
    tutorial.start lesson if lesson?

    e.stopPropagation() if matched is true
    return true
