
jQuery ->

  $('#left').ajaxComplete (e,xhr, settings) ->
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

    if url.match(/ws\/pending/)
      target = $('#pane-grd-ws')
      key = 'wks'
      # menu = 'per-grd-ws'
    else if url.match(/pages\/pending/)
      target = $('#pane-grd-page')
      key = 'pages'
      # karo.tab.enable 'tab-grd-page'
    else if url.match(/gr\/pending/)
      fdb.initialize json
      fdb.attach()
      preview.load fdb.current.scan, 'locker'
      rubric.show()
    else if url.match(/audit\/done/)
      auditForm = $('#m-audit-form')
      entries = $('#pane-audit-review').children('.line')
      current = entries.filter('.selected').eq(0)
      current.removeClass('selected').addClass('disabled')

      $(m).prop 'checked', false for m in auditForm.find("input[type='checkbox']")
      auditForm.find('textarea').eq(0).val null
      auditForm.modal 'hide'
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
  
  ########################################################
  # Other .... 
  ########################################################

  $('#grading-canvas').on 'click', (event) ->
    return canvas.record event

