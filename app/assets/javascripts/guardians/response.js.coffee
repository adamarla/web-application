
jQuery ->
  $('#m-buy-credits').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/guardian\/buy_credit/)
      if json.status is 'ok'
        $('#m-buy-credits').modal 'hide'
        notifier.show 'n-purchase-complete'
        $('#balance').text "Your balance now is #{json.notify.text}"
      else
        $('#m-buy-credits message').text json.notify.text[0]
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst, pgn, pgnUrl

    e.stopPropagation() if matched is true
    return true
