
window.wsTailor = {
  root : null,
  target : null,

  initialize : () ->
    unless root?
      wsTailor.root = $('#m-ws-options')
      wsTailor.target = $('#form-wsb-3').find('.ws-option').eq(0)
    return true

  rewind : () ->
    wsTailor.initialize()
    options = wsTailor.root.find('.ws-option')
    details = wsTailor.root.find('.ws-detail')

    for m in options
      $(m).removeClass 'hide offset1'
      $(n).addClass('hide') for n in $(m).find('.detail') # %p.detail
      $(n).removeClass('disabled') for n in $(m).find("p:not([class~='detail'])") # %p.detail
    options.eq(0).addClass 'offset1'

    $(m).addClass('hide') for m in wsTailor.root.find('.ws-detail')
    
    # Check the first radio buttons. Can't seem to figure out how to do it in HAML
    for m in wsTailor.root.find('form')
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
      obj = wsTailor.root.find "##{m}"
      obj.removeClass 'hide'

    return true
}

jQuery ->
  #########################################################
  ## [wsb]: Selecting the type of a worksheet 
  #########################################################

  $('#m-ws-options').on 'click', '.ws-option', (event) ->
    event.stopImmediatePropagation()
    wsTailor.show $(this)

    id = $(this).attr 'id'
    target = wsTailor.target.find("input[name]")
    $(m).val(null) for m in target # clear them all out

    type = target.filter("[name='ws_type']")

    switch id
      when 'as-homework'
        type.val 'homework'
      when 'as-takehome'
        type.val 'takehome'
      when 'as-classwork'
        type.val 'classwork'

    return true

  $('#m-ws-options').on 'click', 'a.go-back', (event) ->
    event.stopImmediatePropagation()
    wsTailor.rewind()
    return true

  $('#m-ws-options').on 'click', 'a.submit', (event) ->
    event.stopImmediatePropagation()
    wsTailor.root.modal 'hide'
    form = wsTailor.target.closest('form')
    form.submit()
    return true

  $('#m-ws-options').on 'click', "input[type='radio']", (event) ->
    form = $(this).closest 'form'
    for_deadline = form.hasClass('deadline')

    j = wsTailor.target.find("input[name]")
    target = if for_deadline then j.filter("[name='deadline']") else j.filter("[name='duration']")
    value = $(this).val()
    target.val value

    # alert "Deadline: #{for_deadline}, Value: #{value}"
    return true
