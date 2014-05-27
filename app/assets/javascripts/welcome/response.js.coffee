
############################################################################
## Bootstrap 
############################################################################

jQuery ->
  $('#m-register, #m-buy-credits').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    parentKey = null
    childKey = null
    menu = null # ID of contextual menu to attach w/ each .line
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/match\/student/)
      $('#m-register').modal 'hide'

      if json.exists is false
        notifier.show 'n-missing-sektion'
      else if json.enrolled is true
        notifier.show 'n-enrolled-already'
      else if json.blocked is true
        notifier.show 'n-enrollment-blocked'
      else
        # target = $('#sk-confirm-identity')
        a = $('#m-enrollment-confirm')
        target = a.find('#sk-confirm-identity')
        karo.empty target
        key = 'candidates'
        a.modal 'show'
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst

    e.stopPropagation() if matched is true
    return true
