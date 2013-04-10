
jQuery ->

  $('#left').ajaxComplete (e,xhr, settings) ->
    url = settings.url
    matched = true
    json = $.parseJSON xhr.responseText

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .single-line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .single-line
    buttons = null

    if url.match(/untagged\/list/)
      target = $('#pane-tag-pending')
      key = 'pending'
    else if url.match(/vertical\/topics/)
      target = $('#pane-vertical-topics')
      key = 'topics'
    else if url.match(/typeset\/new/)
      target = $('#pane-typeset-new')
      key = 'typeset'
      clickFirst = true
      menu = 'blockdb-slots'
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    if target? and target.length isnt 0
      writeData = if key? then true else false
      # Render the returned JSON - in columns if so desired
      lines.columnify target, json[key], menu, buttons if writeData

      # Enable / disable paginator as needed 
      if json.last_pg?
        pagination.enable pgn, json.last_pg
        # pagination.url.set pgn, pgnUrl

      # Auto-click first line - if needed
      target.children('.single-line').eq(0).click() if clickFirst

    e.stopPropagation() if matched is true
    return true

  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide').ajaxComplete (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match(/suggestion\/preview/)
      preview.loadJson json, 'locker'
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true
