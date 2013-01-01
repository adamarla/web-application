

window.grtb = {
  ul : null,
  current : null, # <li.active>

  show : () ->
    return false unless grtb.current?
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
  
