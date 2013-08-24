
jQuery ->

  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .single-line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .single-line
    buttons = null

    if url.match(/verticals\/list/)
      target = $('#pane-mng-topics-1')
      key = 'verticals'
    else if url.match(/vertical\/topics/)
      karo.tab.enable 'tab-mng-topics-2'
      target = $('#pane-mng-topics-2')
      key = 'topics'
    else if url.match(/byCountry/)
      target = $('#pane-teacher-accounts')
      key = 'accounts'
    else if url.match(/inCountry/)
      target = $('#accounts-in-country')
      key = 'accounts'
      karo.empty target
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst, pgn, pgnUrl

    e.stopPropagation() if matched is true
    return true
