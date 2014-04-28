
window.eTailor = {
  root : null,
  target : null,

  initialize : () ->
    unless root?
      eTailor.root = $('#m-exbopts-1')
      eTailor.target = $('#form-exb-3').find('.exbopt').eq(0)

    # Disable the 'Make PDF' button initially
    eTailor.root.find('button').prop 'disabled', true
    return true

  rewind : () ->
    eTailor.initialize()
    options = eTailor.root.find('.exbopt')
    details = eTailor.root.find('.ws-detail')

    for m in options
      $(m).removeClass 'hide offset1'
      $(n).addClass('hide') for n in $(m).find('.detail') # %p.detail
      $(n).removeClass('disabled') for n in $(m).find("p:not([class~='detail'])") # %p.detail
    options.eq(0).addClass 'offset1'

    $(m).addClass('hide') for m in eTailor.root.find('.ws-detail')
    
    # Check the first radio buttons. Can't seem to figure out how to do it in HAML
    for m in eTailor.root.find('form')
      rb = $(m).find("input[type='radio']").eq(0)
      rb.prop 'checked', true
    return true

  show : (option) ->
    # hide all other siblings and offset $(this) 
    $(m).addClass('hide') for m in option.siblings(":not(p)")
    option.addClass('offset1')

    # unhide any %p.detail within 'option'
    $(p).removeClass('hide') for p in option.find(".detail")

    # gray-out the first %p so that focus is only on the %p.detail
    $(p).addClass('disabled') for p in option.find("p:not([class~='detail'])")

    # unhide any ws-detail - as required
    show = option[0].getAttribute 'data-show'
    show = if show? then show.split(' ') else []
    for m in show
      obj = eTailor.root.find "##{m}"
      obj.removeClass 'hide'

    return true
}

jQuery ->
  #########################################################
  ## [wsb]: Selecting the type of a worksheet 
  #########################################################

  $('#m-exbopts-1').on 'click', '.exbopt', (event) ->
    event.stopImmediatePropagation()
    # eTailor.show $(this)

    id = $(this).attr 'id'
    target = eTailor.target.find("input[name]")
    $(m).val(null) for m in target # clear them all out

    type = target.filter("[name='etype']")
    isClicked = $(this).hasClass 'selected'
    btn = $(this).parent().find 'button'

    switch id
      when 'as-homework'
        x = if isClicked then null else 'homework'
      when 'as-takehome'
        x = if isClicked then null else 'takehome'
      when 'as-classwork'
        x = if isClicked then null else 'classwork'

    type.val x
    if isClicked
      $(this).removeClass 'selected'
      btn.prop 'disabled', true
    else
      $(this).addClass 'selected'
      $(m).removeClass('selected') for m in $(this).siblings()
      btn.prop 'disabled', false

    return true

  $('#m-exbopts-1').on 'click', 'a.go-back', (event) ->
    event.stopImmediatePropagation()
    eTailor.rewind()
    return true

  $('#m-exbopts-1').on 'click', 'a.submit, button', (event) ->
    event.stopImmediatePropagation()
    eTailor.root.modal 'hide'
    form = eTailor.target.closest('form')
    form.submit()
    return true

  $('#m-exbopts-1').on 'click', "input[type='radio']", (event) ->
    form = $(this).closest 'form'
    for_deadline = form.hasClass('deadline')

    j = eTailor.target.find("input[name]")
    target = if for_deadline then j.filter("[name='deadline']") else j.filter("[name='duration']")
    value = $(this).val()
    target.val value

    # alert "Deadline: #{for_deadline}, Value: #{value}"
    return true
