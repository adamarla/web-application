
window.buttonGroup = {
  initialize : (obj) ->
    return false unless obj.hasClass 'btn-group'
    for m in obj.children('button')
      $(m).removeClass 'active'
      for z in $(m).children('input[type]')
        $(z).prop 'checked', false
    return true

  click : (button) ->
    unclick = button.hasClass 'active'
    if unclick then button.removeClass('active') else button.addClass('active')

    # toggle = button.parent()[0].dataset.toggle
    toggle = button.parent()[0].getAttribute('data-toggle')

    children = button.children()

    # Either <button> has a radio-button or a checkbox within it - not both
    radio = children.filter("[type='radio']").eq(0)
    if radio.length isnt 0
      radio.prop 'checked', not unclick
      if not unclick and toggle is 'buttons-radio'
        for m in button.siblings('button')
          r = $(m).children("input[type='radio']")
          if r.length > 0
            $(m).removeClass 'active'
            $(j).prop 'checked', false for j in r
    else
      cb = children.filter("[type='checkbox']").eq(0)
      cb.prop 'checked', not unclick if cb.length isnt 0
    return true
}
