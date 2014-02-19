
jQuery ->

  $('#left').ajaxSuccess (e,xhr, settings) ->
    url = settings.url
    matched = true
    json = $.parseJSON xhr.responseText

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/exams\/list/)
      target = if json.user is "Student" then $('#pane-st-rc-1') else $('#pane-tc-rc-1')
      karo.empty target
      key = 'exams'
    else if url.match(/question\/preview/)
      $('#overlay-preview-carousel').addClass 'hide'
      $('#wide-wait').addClass 'hide'
      $('#wide-X').removeClass 'hide'
      preview.loadJson json # vault; works without this?
    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst, pgn, pgnUrl

    e.stopPropagation() if matched is true
    return true

