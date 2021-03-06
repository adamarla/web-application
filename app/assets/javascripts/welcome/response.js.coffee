
############################################################################
## Bootstrap 
############################################################################

#jQuery ->
#  $('#m-register, #m-buy-credits').ajaxSuccess (e,xhr,settings) ->
#    json = $.parseJSON xhr.responseText
#    url = settings.url
#    matched = true
#
#    target = null # where to write the returned JSON
#    parentKey = null
#    childKey = null
#    menu = null # ID of contextual menu to attach w/ each .line
#    clickFirst = false # whether or not to auto-click the first .line
#    buttons = null
#
#    # if ... else here
#    matched = false
#
#    ############################################################
#    ## Common actions in response to JSON
#    ############################################################
#
#    # Render lines in the panel
#    lines.render target, key, json, menu, buttons, clickFirst
#
#    e.stopPropagation() if matched is true
#    return true

jQuery ->

  $(document).ajaxSuccess (e, xhr, settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = $('.chart')
    if url.match(/attempt\/by_day/)
      usageReport.byDay json, target
    else if url.match(/wtp\/by_user/)
      usageReport.byWtp json, target
    else if url.match(/usage\/by_user/)
      usageReport.byBucket json, target
    else if url.match(/attempt\/by_week/)
      usageReport.byWeek json, target
    else
      matched = false

    e.stopPropagation() if matched is true
    return true

  $(document).ajaxError (e, xhr, settings) ->
    url = settings.url
    return true
