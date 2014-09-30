
############################################################################
## Bootstrap 
############################################################################

jQuery ->
  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText

    if json.render? and not json.render
      e.stopImmediatePropagation() 
      return true 

    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    parentKey = null
    childKey = null
    menu = null # ID of contextual menu to attach w/ each .line
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/inbox$/)
      target = $('#pane-st-inbox')
      karo.empty target
      key = 'inbox'
      clickFirst = true
    else if url.match(/stab\/load/)
      scalpel.load json
    else if url.match(/stab\/bell-curve/)
      notifier.show 'n-stab-bell'
      scalpel.bell.render json
    else if url.match(/stabs/)
      key = 'stabs'
      clickFirst = true
      if url.match(/dated/) #stabs/dated
        target = $('#pane-st-stabs-2') 
        karo.empty target
        scalpel.attach 'wide-Y'
      else # => stabs/graded 
        target = $('#pane-st-stabs-1')
    else if url.match(/worksheet\/preview/) or url.match(/worksheet\/scans/)
      overlay.detach()
      preview.loadJson json

    else if url.match(/course\/list/)
      e.stopImmediatePropagation()
      return tiles.render(json.tiles)

    else if url.match(/load\/course/)
      e.stopImmediatePropagation()
      return exploded.initialize(json.course)
      
    else if url.match(/course\/quizzes/)
      target = $('#pane-expld-quizzes')
      key = 'quizzes'
      menu = 'per-qz'
      monitor.add json

    else if url.match(/ping\/queue/)
      monitor.update json
      exploded.update json

    else if url.match(/outbox$/)
      target = $('#pane-st-outbox')
      karo.empty target
      key = 'outbox'
      clickFirst = true
    else if url.match(/match\/student/)
      $('#m-enroll-self').modal 'hide'

      if json.exists is false
        notifier.show 'n-missing-sektion'
      else if json.enrolled is true
        notifier.show 'n-enrolled-already'
      else if json.blocked is true
        notifier.show 'n-enrollment-blocked'
      else
        buttons = [ { cbx: 'checked' } ]
        mdl = $('#m-enrollment-confirm')
        target = mdl.find '#sk-confirm-identity' 
        submitBtn = mdl.find("button[id='btn-enroll-me']")
        submitBtn.prop 'disabled', true
        karo.empty target
        key = 'candidates'
        mdl.modal 'show'
    else if url.match(/merge$/)
      $('#m-enrollment-confirm').modal 'hide'
      trigger.click $('#a-st-main')[0] # auto-load the report cards for the merged account
    else if url.match(/dispute/)
      m = $('#m-dispute-2')
      m.find('textarea').val null
      m.modal 'hide'
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst

    e.stopPropagation() if matched is true
    return true
