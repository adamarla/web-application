

window.rubric = { 
  root : null, 
  audience : null, # who is viewing the rubric 
  grading : false, # false => only viewing. Set by initial ping callback and never again 
  typing : false, # false => writing a comment
  form : null,
  buttons : null,
  locked : false,

  initialize : (node) ->
    rubric.root = if typeof node is 'string' then $(node)[0] else node
    $(rubric.root).empty() 

    rubric.typing = false

    if rubric.audience is 'Examiner'
      rubric.form = $(rubric.root).closest('form')[0]
      $(rubric.form).submit rubric.submitFdb

      # An examiner sees two rubrics - this one (will go in time) and one for 
      # stabs (will stay). As both share keyboard shortcuts, we must ensure 
      # that only the last initialized one processes key-presses and mouse-clicks 

      stabs.lock()
      rubric.unlock() 

    else 
      rubric.form = null
      $('body').off 'keyup', rubric.pressKey 
      $('body').off 'click', rubric.mouseClick 

    # Attach the standard buttons - after trimming the extraneous ones  

    btns = $('#toolbox > #rubric-standard-btns').clone()

    if rubric.audience is 'Examiner' or rubric.audience is 'Teacher' 
      b = btns.find('button[data-karo=regrade]').eq(0)
      b.remove() 

    btns.appendTo $(rubric.root)
    rubric.buttons = btns[0] 
    $(rubric.buttons).on 'click', 'button', rubric.clickBtn 
    $(rubric.buttons).on 'ajaxSuccess', rubric.processJson
    return true 

  lock : () ->
    rubric.locked = true 
    overlay.detach()
    fdb.detach() 
    $('body').off 'keyup', rubric.pressKey 
    $('body').off 'click', rubric.mouseClick 

    if rubric.form? 
      $(rubric.form).off 'ajaxSuccess', rubric.postSubmitCallBk
    return true 

  unlock : () ->
    rubric.locked = false 
    $('body').on 'keyup', rubric.pressKey 
    $('body').on 'click', rubric.mouseClick 
    if rubric.form? 
      $(rubric.form).on 'ajaxSuccess', rubric.postSubmitCallBk
    return true

  reset : () ->
    # unselect all criteria 
    for m in $(rubric.root).children('.criterion')
      $(m).removeClass 'selected'
      $(m).find("input[type='checkbox']").eq(0).prop 'checked', false

    # clear just submitted feedback and move to next scan 
    fdb.clear()
    $(fdb.current.response).addClass 'graded'
    fdb.next.response()
    return true 

  processJson : (e, xhr, settings) ->
    url = settings.url 
    matched = true

    if url.match(/scans\/pending/) # when grading 
      rubric.buttonsOff false 
    else if url.match(/load\/fdb/) # viewing feedback !!!!!!!
      json = $.parseJSON xhr.responseText 
      $(rubric.buttons).attr('marker', json.id) if rubric.buttons? 
      rubric.render(json.criteria) if json.criteria?

      # load scan and overlay comments - if any
      if json.preview? 
        preview.loadJson json
        if json.comments?
          overlay.attach $(preview.root)
          overlay.loadJson json.comments

      # enable / disable buttons as needed 
      rubric.buttonsOff true 
      for j in ['solution', 'audit', 'regrade']
        continue unless json[j]
        b = $(rubric.buttons).find("button[data-karo=#{j}]")[0]
        if b?
          $(b).removeClass 'disabled' 
          $(b).prop 'disabled', false

    else # no match !!!  
      matched = false 

    e.stopImmediatePropagation() if matched 
    return true 

  postSubmitCallBk : (e, xhr, settings) ->
    url = settings.url 
    if url.match(/record\/fdb/)
      e.stopImmediatePropagation() 
      rubric.reset()
    return true

  render : (json) ->
    return false unless rubric.root? 
    karo.empty $(rubric.root)

    for m,j in json
      nd = criteria.render m
      if rubric.grading
        klass = if (j % 2 is 0) then 'grade' else 'grade highlight'
      else 
        klass = if (j % 2 is 0) then 'view' else 'view highlight'
      nd.addClass(klass) # for differential styling in feedback panel 
      nd.appendTo $(rubric.root)

    rubric.buttonsOff true # re-enable in response to JSON
    return true 

  isBlankFdb : () ->
    return false unless rubric.form?
    notBlank = false 

    for c in $(rubric.form).find '.criterion'
      cbx = $(c).children('input[type=checkbox]').eq(0)
      notBlank = notBlank or  cbx.prop('checked')
      break if notBlank
    return notBlank

  submitFdb : (event) ->
    proceed = rubric.isBlankFdb() and (fdb.given.length > 0)
    unless proceed 
      return false 

    if sandbox.enabled 
      rubric.reset()
    else 
      id = $(fdb.current.response).attr 'marker'
      overlay = fdb.decompile()
      action = "record/fdb.json?id=#{id}&overlay=#{overlay}"
      $(this).attr 'action', action
    return !sandbox.enabled

  pressKey : (event) -> 
    return true if (rubric.locked || rubric.typing)
    event.stopImmediatePropagation() 
    # The keypress is either of a key that is reserved for the rubric or 
    # for a key reserved by fdb-controls

    key = String.fromCharCode(event.which)
    # alert "rubric --> #{event.which} --> #{key}"

    nd = $(rubric.root).children().filter("[data-kb='#{key}']")[0]
    if nd? 
      criteria.select nd
    else 
      fdb.pressKey event
      return true 

  mouseClick : (event) ->
    return true if (rubric.locked || rubric.typing)
    tex = $(shadow.commentBox).val()
    return true if /^\s*$/.test(tex) # empty string 

    event.stopImmediatePropagation() 
    $(shadow.commentBox).val '' # clear it 
    unique = true
    for m in fdb.history 
      if m is tex
        unique = false 
        break
    fdb.history.push tex if unique 
    fdb.add tex, event 
    return true

  clickBtn : (event) ->
    btn = event.target
    karo = btn.getAttribute 'data-karo'
    event.stopImmediatePropagation()
    $(m).removeClass('active') for m in $(btn).siblings()

    id = $(rubric.buttons).attr('marker') || $(fdb.current.response).attr 'marker'

    switch karo 
      when 'solution'
        if $(btn).hasClass 'active' # => viewing solution
          $(btn).removeClass 'active'
          if rubric.grading 
            fdb.attach()
            fdb.update.view(false)
          else 
            $.get "load/fdb?id=#{id}&type=g"
        else
          $(btn).addClass 'active'
          fdb.detach() if rubric.grading
          $.get "question/preview?id=#{id}&type=g", (json) ->
            overlay.clear() 
            preview.loadJson json
      when 'audit'
        mdl = $('#m-audit-form')
        fm = mdl.find('form')[0]
        $(fm).attr 'action', "audit/open?id=#{id}&type=g"
        mdl.modal 'show'
        rubric.typing = true
      when 'regrade'
        mdl_1 = $('#m-dispute-1')
        fm = $('#m-dispute-2 form')
        fm.attr 'action', "dispute?id=#{id}"
        mdl_1.modal 'show'
        rubric.typing = true
    return true

  buttonsOff : (state = true) -> # true => disabled
    for b in $(rubric.buttons).find('button')
      $(b).prop 'disabled', state
      if state then $(b).addClass('disabled') else $(b).removeClass('disabled')
    return true
} 

jQuery -> 
  $('.tab-pane').on 'click', '.criterion', (event) ->
    event.stopImmediatePropagation() 
    return false unless rubric.grading 
    criteria.select this
    return true
