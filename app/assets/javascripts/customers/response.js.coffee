
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

    if url.match(/customer\/list/)
      target = $('#')
      key = 'customers'
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
    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst, pgn, pgnUrl

    e.stopPropagation() if matched is true
    return true

  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide').ajaxComplete (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match(/question\/preview/)
      $('#wide-wait').addClass 'hide'
      $('#wide-X').removeClass 'hide'
      preview.loadJson json # vault 
      if json.context is 'qzb' # [#108]: possible only with teachers! 
        tutorial.start 'qzb-milestone-6'
        $('#m-audit-form').find('form').eq(0).attr 'action', "/audit/done?id=#{json.a}"
    else if url.match(/rotate_scan/)
      fdb.next.scan()
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true
  
