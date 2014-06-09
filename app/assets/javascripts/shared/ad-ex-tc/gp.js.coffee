

window.gp = {
  root : null,
  ul : null,
  form : null,
  current : null, # <li.active>
  keyboard : false,

  show : () ->
    return false unless gp.current?
    gp.current.removeClass 'disabled'
    # disable and reset all * subsequent * tabs 
    for m in gp.current.nextAll('li')
      $(m).addClass 'disabled'
      gp.reset $(m)

    # Enable the feedback submit button only if on the last tab
    submitBtn = $('#btn-submit-fdb')

    # Ensure that the 'Show Solution' & 'Audit Key' buttons are enabled
    $(m).prop('disabled', false) for m in submitBtn.siblings()

    if gp.current.next().length isnt 0
      submitBtn.addClass 'disabled'
      submitBtn.prop 'disabled', true
    else
      submitBtn.removeClass 'disabled'
      submitBtn.prop 'disabled', false

    a = gp.current.children('a').eq(0)
    karo.tab.enable a.attr('id')
    return true

  reset : (li) ->
    # li as in ul.nav-tabs > li
    pane = li.children('a').eq(0).attr('href')
    content = li.parent().next()
    pane = content.children("#{pane}").eq(0)
    for k in $(pane).children('.requirement')
      $(k).removeClass 'selected'
      $(cb).prop 'checked', false for cb in $(k).find("input[type='checkbox']")
    return true

  rewind : () ->
    gp.current = gp.ul.children('li').eq(0)
    gp.reset gp.current
    gp.show()
    return false

  select : (n) -> # n-th .requirement in currently active tab/pane, 0 < n < 10
    active = gp.ul.next().children('.active').eq(0)
    target = active.children('.requirement').eq(n)
    return true if target.length is 0
    target.click()
    return true

}

jQuery ->

  unless gp.ul?
    gp.ul = $('#form-feedback').find('ul.nav-tabs').eq(0)
    gp.current = gp.ul.children('li').eq(0)
    gp.root = gp.ul.parent()
    gp.form = gp.root.parent()

  #####################################################################
  ## Enable / disable keyboard shortcuts 
  #####################################################################

  $('#tab-grd-ws, #tab-grd-page').on 'shown', (event) ->
    gp.keyboard = false
    return true

  $('#tab-grd-panel').on 'shown', (event) ->
    gp.keyboard = true
    return true

  #####################################################################
  ## Behaviour of the Grading feedback  
  #####################################################################

  gp.ul.on 'click', 'li', (event) ->
    event.stopPropagation()
    return false unless gp.keyboard # disable mouse-clicks too
    return false if $(this).hasClass 'disabled'

    gp.current = $(this)
    gp.show()
    return false # to prevent screen scrolling up

  gp.root.on 'click', '.requirement', (event) ->
    event.stopImmediatePropagation()
    return false unless gp.keyboard # disable mouse-clicks too

    multiOk = $(this).parent().hasClass 'multi-select'
    already = $(this).hasClass 'selected'

    if already
      $(this).removeClass 'selected'
      $(this).find("input[type='checkbox']").eq(0).prop 'checked', false
    else
      $(this).addClass 'selected'
      $(this).find("input[type='checkbox']").eq(0).prop 'checked', true

    unless multiOk
      for m in $(this).siblings('.requirement')
        $(m).removeClass 'selected'
        $(m).find("input[type='checkbox']").eq(0).prop 'checked', false

      # Move to the next tab
      unless already
        gp.current = gp.current.next()
        gp.show()
    return true

  gp.form.submit (event) ->
    if not fdb.given.length > 0 
      alert "Add atleast a comment or annotate with a check, cross or question mark"
      return false

    unless sandbox.enabled 
      id = $(fdb.current.response).attr 'marker'
      overlay = fdb.decompile()
      action = "submit/fdb.json?id=#{id}&overlay=#{overlay}"
      # alert action
      $(this).attr 'action', action
    else 
      fdb.clear()
      $(fdb.current.response).addClass 'graded'
      fdb.next.response()
      gp.rewind()
      
    return !sandbox.enabled


  #####################################################################
  ## On successful submission of feedback 
  #####################################################################

  gp.form.ajaxComplete (event, xhr,settings) ->
    url = settings.url
    matched = true

    if url.match(/submit\/fdb/)
      fdb.clear()
      $(fdb.current.response).addClass 'graded'
      fdb.next.response()
      gp.rewind()
    else
      matched = false

    event.stopPropagation() if matched is true
    return true

  #####################################################################
  ## Keyboard shortcuts to speed-up grading
  #####################################################################

  $('body').on 'keypress', (event) ->
    event.stopImmediatePropagation()
    return true unless gp.keyboard

    lp = $('#left').children('#left-4').eq(0)
    if lp.hasClass 'hide'
      gp.keyboard = false
      return true
    pane = lp.children().eq(1).children('#pane-grd-panel').eq(0)
    unless pane.hasClass 'active'
      gp.keyboard = false
      return true

    key = event.which

    unless (key < 49 || key > 57) # numbers 1-9
      gp.select( key - 49 )
    else if key is 115 # S => submit
      gp.form.submit() if gp.current.next().length is 0
    else 
      # alert key
      switch key 
        when 98 # B
          id = 'btn-blank'
        when 99 # C 
          id = 'btn-cheated'
        when 112 # P 
          id = 'btn-perfect'
        when 102  #F
          id = 'btn-rotate'
        when 104  #H
          id = 'btn-what'
        when 105 #I
          id = 'btn-hide-controls'
        when 93  # ]
          id = 'btn-next-scan'
        when 91  # [
          id = 'btn-prev-scan'
        when 114  #R
          id = 'btn-fresh-copy'
        when 116  #T
          id = 'btn-ok' 
        when 117  #U
          id = 'btn-undo' 
        when 119  #W 
          id = 'btn-write'
        when 120  #X
          id = 'btn-cross'
        when 44  # < 
          id = 'btn-prev-ques'
        when 46  # >
          id = 'btn-next-ques'
        else 
          id = nil

      if id?
        buttons = $(fdb.root).find 'button'
        btn = buttons.filter("[id=#{id}]")[0]
        $(btn).click() if btn?

    return true

  #####################################################################
  ## If btn-submit-fdb is explicitly clicked 
  #####################################################################
  $('#btn-submit-fdb').click (event) ->
    event.stopPropagation()
    gp.form.submit()
    return true


  #####################################################################
  ## Toggle between answer-key preview and grading 
  #####################################################################

  $('#btn-toggle-answerkey').click (event) ->
    event.stopPropagation()
    backToGrading = $(this).hasClass('active')
    gp.keyboard = backToGrading

    if backToGrading
      $(this).text("See Solution")
      $(this).removeClass 'active'
      fdb.attach()
      fdb.update.view(false)
    else
      $(this).text("Back to Grading")
      $(this).addClass 'active'
      id = $(fdb.current.response).attr 'marker'
      fdb.detach()
      $.get "question/preview?gr=#{id}"
    return true

  #####################################################################
  ## Show audit form if grader sees issues w/ answer key during grading 
  #####################################################################

  $('#btn-audit-key').click (event) ->
    event.stopImmediatePropagation()
    audit = $('#m-audit-form')
    form = audit.find('form')[0]

    audit.modal 'show'
    action = form.getAttribute 'data-action'
    pattern = /gr=[\d]+/
    result = pattern.exec action
    action = action.replace result,"gr=#{$(fdb.current.response).attr('marker')}"
    form.setAttribute 'data-action', action

    gp.keyboard = false # disable keyboard - if auditing during grading
    return false


