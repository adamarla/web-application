
jQuery ->

  $('#left').ajaxComplete (e,xhr, settings) ->
    url = settings.url
    matched = true
    json = $.parseJSON xhr.responseText

    target = null # where to write the returned JSON
    parentKey = null
    childKey = null
    menu = null # ID of contextual menu to attach w/ each .single-line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .single-line

    if url.match(/ws\/pending/)
      target = $('#pane-grd-ws')
      parentKey = 'wks'
      childKey = 'wk'
      menu = 'per-grd-ws'
    else if url.match(/pages\/pending/)
      target = $('#pane-grd-page')
      parentKey = 'pages'
      childKey = 'page'
      # karo.tab.enable 'tab-grd-page'
    else if url.match(/gr\/pending/)
      abacus.initialize json
      grtb.show()
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

  ###
  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    url = settings.url
    matched = true
    json = $.parseJSON xhr.responseText

    if url.match(/comments\/for/)
      here = $('#side-panel').children().eq(0).find('.calibrations').eq(0)
      coreUtil.interface.grades.initializePanel here
      coreUtil.interface.grades.summarize json, here
      coreUtil.interface.grades.loadDetails json, here
    else
      matched = false

    e.stopPropagation() if matched is true
    return true
  ###
  
  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide').ajaxComplete (e, xhr, settings) ->
    matched = settings.url.match(/quiz\/preview/) or
              settings.url.match(/question\/preview/)
    return if matched is null

    e.stopImmediatePropagation()
    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'quiz/candidate_questions'
        preview.loadJson json, 'vault'
      when 'question/preview'
        $('#wide-wait').addClass 'hide'
        $('#wide-X').removeClass 'hide'
        preview.loadJson json, 'vault'
        ###
          When tagging questions, load any prior info about the question's 
          difficulty and availability onto the <select>s in #misc-traits
        ###

        ###
        misc = $('#side-panel').find '#misc-traits'
        if misc.length isnt 0
          restricted = misc.find '#misc_restricted'
          restricted.val json.preview.restricted unless not restricted?
          diff = misc.find '#misc_difficulty'
          diff.val json.preview.difficulty unless not diff?
        ###
      when 'quiz/preview'
        preview.loadJson json, 'atm'
    return true
  
  ########################################################
  # Other .... 
  ########################################################

  $('#grading-canvas').on 'click', (event) ->
    return canvas.record event

