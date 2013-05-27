
############################################################################
## Bootstrap 
############################################################################

jQuery ->
  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    parentKey = null
    childKey = null
    menu = null # ID of contextual menu to attach w/ each .single-line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .single-line
    buttons = null

    if url.match(/ws-preview/)
      preview.loadJson json, 'locker'
    else if url.match(/inbox\/echo/)
      preview.loadJson json, 'atm' 
      return true
    else if url.match(/inbox/)
      target = $('#pane-st-inbox')
      parentKey = 'inbox'
      childKey = 'ws'
      menu = 'st-inbox'
      clickFirst = true
    else if url.match(/outbox/)
    else if url.match(/enroll/)
      $('#m-enroll-self').modal 'hide'
      if json.block is true
        $('#m-enrollment-blocked').modal 'show'
      else
        target = $('#sk-confirm-identity')
        karo.empty target
        key = 'candidates'
        $('#m-enrollment-confirm').modal 'show'
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
