

window.rubric = {
  root : null,
  ul : null,
  form : null,
  current : null, # <li.active>
  keyboard : false,

  show : () ->
    return false unless rubric.current?
    rubric.current.removeClass 'disabled'
    # disable and reset all * subsequent * tabs 
    for m in rubric.current.nextAll('li')
      $(m).addClass 'disabled'
      rubric.reset $(m)

    # Enable the feedback submit button only if on the last tab
    submitBtn = $('#btn-submit-fdb')

    # Ensure that the 'Show Solution' & 'Audit Key' buttons are enabled
    $(m).prop('disabled', false) for m in submitBtn.siblings()

    if rubric.current.next().length isnt 0
      submitBtn.addClass 'disabled'
      submitBtn.prop 'disabled', true
    else
      submitBtn.removeClass 'disabled'
      submitBtn.prop 'disabled', false

    a = rubric.current.children('a').eq(0)
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
    rubric.current = rubric.ul.children('li').eq(0)
    rubric.reset rubric.current
    rubric.show()
    return false

  select : (n) -> # n-th .requirement in currently active tab/pane, 0 < n < 10
    active = rubric.ul.next().children('.active').eq(0)
    target = active.children('.requirement').eq(n)
    return true if target.length is 0
    target.click()
    return true

}

jQuery ->

  unless rubric.ul?
    rubric.ul = $('#form-feedback').find('ul.nav-tabs').eq(0)
    rubric.current = rubric.ul.children('li').eq(0)
    rubric.root = rubric.ul.parent()
    rubric.form = rubric.root.parent()

  #####################################################################
  ## Enable / disable keyboard shortcuts 
  #####################################################################

  $('#tab-grd-ws, #tab-grd-page').on 'shown', (event) ->
    rubric.keyboard = false
    return true

  $('#tab-grd-panel').on 'shown', (event) ->
    rubric.keyboard = true
    return true

  #####################################################################
  ## Behaviour of the Grading feedback  
  #####################################################################

  rubric.ul.on 'click', 'li', (event) ->
    event.stopPropagation()
    return false unless rubric.keyboard # disable mouse-clicks too
    return false if $(this).hasClass 'disabled'

    rubric.current = $(this)
    rubric.show()
    return false # to prevent screen scrolling up

  rubric.root.on 'click', '.requirement', (event) ->
    event.stopImmediatePropagation()
    return false unless rubric.keyboard # disable mouse-clicks too

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
        rubric.current = rubric.current.next()
        rubric.show()
    return true

  rubric.form.submit (event) ->
    if not fdb.given.length > 0 
      alert "Add atleast a comment or annotate with a check, cross or question mark"
      return false

    id = fdb.current.response.attr 'marker'
    overlay = fdb.decompile()
    action = "submit/fdb.json?id=#{id}&overlay=#{overlay}"
    # alert action
    $(this).attr 'action', action
    return true


  #####################################################################
  ## On successful submission of feedback 
  #####################################################################

  rubric.form.ajaxComplete (event, xhr,settings) ->
    url = settings.url
    matched = true

    if url.match(/submit\/fdb/)
      fdb.clear()
      fdb.next.response()
      rubric.rewind()
    else
      matched = false

    event.stopPropagation() if matched is true
    return true

  #####################################################################
  ## Keyboard shortcuts to speed-up grading
  #####################################################################

  $('body').on 'keypress', (event) ->
    event.stopImmediatePropagation()
    return true unless rubric.keyboard

    lp = $('#left').children('#left-4').eq(0)
    if lp.hasClass 'hide'
      rubric.keyboard = false
      return true
    pane = lp.children().eq(1).children('#pane-grd-panel').eq(0)
    unless pane.hasClass 'active'
      rubric.keyboard = false
      return true

    key = event.which

    unless (key < 49 || key > 57) # numbers 1-9
      rubric.select( key - 49 )
    else if key is 115 # S => submit
      rubric.form.submit() if rubric.current.next().length is 0
    else if (key >= 102 && key <= 122) 
      buttons = $(fdb.root).find 'button'
      switch key 
        when 102  #F
          id = 'btn-rotate'
        when 104  #H
          id = 'btn-what'
        when 110  #N
          id = 'btn-next-scan'
        when 112  #P
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
        when 121  #Y
          id = 'btn-prev-ques'
        when 122  #Z
          id = 'btn-next-ques'

      btn = buttons.filter("[id=#{id}]")[0]
      $(btn).click() if btn?

    return true

  #####################################################################
  ## If btn-submit-fdb is explicitly clicked 
  #####################################################################
  $('#btn-submit-fdb').click (event) ->
    event.stopPropagation()
    rubric.form.submit()
    return true


  #####################################################################
  ## Toggle between answer-key preview and grading 
  #####################################################################

  $('#btn-toggle-answerkey').click (event) ->
    # event.stopPropagation()
    backToGrading = $(this).hasClass('active')
    rubric.keyboard = backToGrading

    if backToGrading
      $(this).text("See Solution")
      fdb.attach()
      preview.load fdb.current.scan.attr('name'), 'locker' 
    else
      $(this).text("Back to Grading")
      id = fdb.current.response.attr 'marker'
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
    action = action.replace result,"gr=#{fdb.current.response.attr('marker')}"
    form.setAttribute 'data-action', action
    return false


