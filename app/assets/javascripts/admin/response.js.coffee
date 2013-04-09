
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

    if url.match(/schools\/list/)
      target = $('#schools')
      key = 'schools'
      pgnUrl = "schools/list"
    else if url.match(/verticals\/list/)
      target = $('#pane-mng-topics-1')
      key = 'verticals'
    else if url.match(/vertical\/topics/)
      karo.tab.enable 'tab-mng-topics-2'
      target = $('#pane-mng-topics-2')
      key = 'topics'
    else if url.match(/byCountry/)
      target = '#pane-teacher-accounts'
      key = 'accounts'
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    if target? and target.length isnt 0
      writeData = if key? then true else false

      # Render the returned JSON - in columns if so desired
      lines.columnify target, json[key], menu, buttons if writeData
      # line.write(target, m[childKey], menu) for m in json[key]

      # Enable / disable paginator as needed 
      if json.last_pg?
        pagination.enable pgn, json.last_pg
        pagination.url.set pgn, pgnUrl

      # Disable / hide any .single-line whose marker is in json.[disabled, hide]
      for m in ['disabled', 'hide']
        continue unless json[m]
        j = target.find('.single-line')
        for k in json[m]
          l = j.filter("[marker=#{k}]")[0]
          $(l).addClass(m) if l?

      # Auto-click first line - if needed

      # Auto-click first line - if needed
      target.children('.single-line').eq(0).click() if clickFirst
      

    e.stopPropagation() if matched is true
    return true
