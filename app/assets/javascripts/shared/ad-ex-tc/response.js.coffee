
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

    if url.match(/ws\/pending/)
      target = $('#pane-grd-ws')
      key = 'wks'
      # menu = 'per-grd-ws'
    else if url.match(/pages\/pending/)
      target = $('#pane-grd-page')
      key = 'pages'
      # karo.tab.enable 'tab-grd-page'
    else if url.match(/gr\/pending/)
      abacus.initialize json
      grtb.show()
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    if target? and target.length isnt 0
      writeData = if key? then true else false
      karo.empty target

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

    if url.match(/quiz\/candidate_questions/)
      preview.loadJson json, 'vault'
    else if url.match(/question\/preview/)
      $('#wide-wait').addClass 'hide'
      $('#wide-X').removeClass 'hide'
      preview.loadJson json, 'vault'
      tutorial.start 'qzb-milestone-6' if json.context is 'qzb'
    else if url.match(/rotate_scan/)
      abacus.next.scan()
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true
  
  ########################################################
  # Other .... 
  ########################################################

  $('#grading-canvas').on 'click', (event) ->
    return canvas.record event

