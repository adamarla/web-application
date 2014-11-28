
jQuery ->

  $('#left').ajaxComplete (e,xhr, settings) ->
    json = $.parseJSON xhr.responseText

    if json.render? and not json.render 
      e.stopImmediatePropagation() 
      return true 

    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/exams\/pending/)
      target = $('#pane-grade-1')
      karo.empty target
      key = 'exams'
      fdb.detach()

    else if url.match(/load\/rubric\/for/)
      rubric.initialize '#div-rubric-criteria'
      rubric.render json.criteria

    else if url.match(/grade\/pending/)
      target = $('#pane-grade-2')
      karo.empty target
      key = 'questions'
      fdb.detach()
    else if url.match(/scans\/pending/)
      fdb.attach()
      fdb.initialize json

    else if url.match(/audit\/open/) or url.match(/close\/apprentice\/audit/)
      isQuestion = if url.match(/audit\/open/)? then true else false

      if isQuestion
        auditForm = $('#m-audit-form')
        entries = $('#pane-audit-review').children('.line')
        current = entries.filter('.selected').eq(0)
        current.removeClass('selected').addClass('disabled')
      else
        auditForm = $('#m-audit-apprentice')

      $(m).prop 'checked', false for m in auditForm.find("input[type='checkbox']")
      auditForm.find('textarea').eq(0).val null
      auditForm.modal 'hide'

    else if url.match(/questions\/on/)
      key = 'questions'
      menu = 'per-question'
      if json.context isnt 'addhints'
        topic = json.topic
        target = $("##{json.context}-pick-#{topic}")
        buttons = [{ icon: 'icon-plus-sign', cbx: 'q' }]
      else
        fdb.detach()
        karo.tab.enable 'tab-audit-4'
        target = $("#pane-audit-4")

    else if url.match(/load\/dispute/)
      preview.loadJson json
      $('#btn-dispute-soln').attr 'marker', json.a
      if json.comments?
        overlay.attach $(preview.root)
        overlay.loadJson json.comments

    else if url.match(/dispute\/reason/)
      notifier.show 'n-dispute-reason', json

    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst

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
      preview.loadJson(json, '#wide-X') # vault 
      if json.context is 'qzb' # [#108]: possible only with teachers! 
        tutorial.start 'qzb-milestone-6'
        $('#m-audit-form').find('form').eq(0).attr 'action', "/audit/open?id=#{json.a}"
    else if url.match(/rotate_scan/)
      fdb.next.scan()
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true
  
  ########################################################
  # Other Stuff ...  
  ########################################################

  $('#btn-dispute-soln').on 'click', (event) ->
    event.stopImmediatePropagation() 
    isActive = $(this).hasClass 'active' 
    id = $(this).attr 'marker'
    return false unless id?

    if isActive 
      $(this).removeClass 'active'
      $.get "load/dispute?id=#{id}"
    else
      $(this).addClass 'active'
      overlay.clear()
      $.get "question/preview?id=#{id}&type=g"
    return true 
