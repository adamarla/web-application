
jQuery ->

  $('#left, #control-panel').ajaxComplete (e,xhr, settings) ->
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

    if url.match(/customers\/list/)
      target = $('#pane-cust')
      key = 'customers'
      menu = 'admin'
      karo.empty target
    else if url.match(/customer\/activity/)
      target = $('#pane-cust-activity')
      key = 'activity'
      clickFirst = true
      karo.empty target
    else if url.match(/document\/transactions/)
      target = $('#transactions')
      key = 'transactions'
      karo.empty target
    else if url.match(/buy\/credits/)
      if json.status is 'ok'
        $('#m-buy-credits').modal 'hide'
        notifier.show 'n-purchase-complete'
      else
        alertbox = $('#m-buy-credits #message')
        alertbox.text json.text
        alertbox.removeClass 'hide'
    else if url.match(/refund/)
      if json.status is 'ok'
        $('#m-refund-credits').modal 'hide'
        notifier.show 'n-purchase-complete'
      else
        alertbox = $('#m-refund-credits #message')
        alertbox.text json.text
        alertbox.removeClass 'hide'
    else if url.match(/credits\/transfer/)
      alertbox = $('#m-transfer #message')
      alertbox.addClass 'hide'
      if json.status is 'error'
        alertbox.text json.message 
        alertbox.removeClass 'hide'
      else
        $('#m-transfer').modal 'hide'
    else if url.match(/gen\/invoice/)
      alertbox = $('#m-invoice #message')
      alertbox.addClass 'hide'
      if json.status is 'error'
        alertbox.text json.message 
        alertbox.removeClass 'hide'
      else
        $('#m-invoice').modal 'hide'
        notifier.show 'n-purchase-complete'
    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst, pgn, pgnUrl

    e.stopPropagation() if matched is true
    return true

