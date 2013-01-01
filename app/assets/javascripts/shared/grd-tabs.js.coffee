

window.grtb = {
  root : null,
  ul : null,
  current : null, # <li.active>

  show : () ->
    return false unless grtb.current?
    grtb.current.removeClass 'disabled'
    # disable all * subsequent * tabs first
    $(m).addClass 'disabled' for m in grtb.current.nextAll('li')

    a = grtb.current.children('a').eq(0)
    karo.tab.enable a.attr 'id'
    return true

}

jQuery ->

  # This script file is called only for roles that can grade => roles that 
  # that can see _grd-abacus. Hence, its safe to assume that #form-feedback is visible

  unless grtb.ul?
    grtb.ul = $('#form-feedback').find('ul.nav-tabs').eq(0)
    grtb.current = grtb.ul.children('li').eq(0)
    grtb.root = grtb.ul.parent()

  #####################################################################
  ## Behaviour of the Grading Abacus  
  #####################################################################

  grtb.ul.on 'click', 'li', (event) ->
    event.stopPropagation()
    return false if $(this).hasClass 'disabled'
    grtb.current = $(this)
    grtb.show()
    return false # to prevent screen scrolling up

  grtb.root.on 'click', '.requirement', (event) ->
    event.stopImmediatePropagation()
    multiOk = $(this).parent().hasClass 'multi-select'
    isSelected = $(this).hasClass 'selected'

    if isSelected
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
      grtb.current = grtb.current.next()
      grtb.show()

    return true

