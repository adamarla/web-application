
############################################################################
## Bootstrap 
############################################################################

jQuery ->
  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    parentKey = null
    childKey = null
    menu = null # ID of contextual menu to attach w/ each .line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/inbox\/echo/)
      # only because /inbox/echo also matches /inbox
    else if url.match(/inbox/)
      target = $('#pane-st-inbox')
      karo.empty target
      key = 'inbox'
      menu = 'st-inbox'
    else if url.match(/outbox/)
    else if url.match(/enroll/)
      $('#m-enroll-self').modal 'hide'

      if json.exists is false
        notifier.show 'n-missing-sektion'
      else if json.enrolled is true
        notifier.show 'n-enrolled-already'
      else if json.blocked is true
        notifier.show 'n-enrollment-blocked'
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

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst, pgn, pgnUrl

    e.stopPropagation() if matched is true
    return true
