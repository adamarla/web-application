
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

    if url.match(/ws-preview/)
      preview.loadJson json, 'locker'
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    if target? and target.length isnt 0
      purge = if target.hasClass('writeonce') then target.children().length is 0 else true
      if purge
        karo.empty target
        line.write(target, m[childKey], menu) for m in json[parentKey]

      # Enable / disable paginator as needed 
      if json.last_pg?
        pagination.enable pgn, json.last_pg
        # pagination.url.set pgn, pgnUrl

      # Auto-click first line - if needed
      target.children('.single-line').eq(0).click() if clickFirst
      

    e.stopPropagation() if matched is true
    return true
