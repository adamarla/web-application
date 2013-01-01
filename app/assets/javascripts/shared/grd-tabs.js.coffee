

window.grtb = {
  root : null,
  ul : null,
  form : null,
  current : null, # <li.active>
  keyboard : false,

  show : () ->
    return false unless grtb.current?
    grtb.current.removeClass 'disabled'

    # disable all * subsequent * tabs first and uncheck all checkboxes within them
    for m in grtb.current.nextAll('li')
      $(m).addClass 'disabled'
      pane = $(m).children('a').eq(0).attr('href')
      $(cb).prop 'checked', false for cb in $(pane).find("input[type='checkbox']")

    a = grtb.current.children('a').eq(0)
    karo.tab.enable a.attr 'id'
    return true

  rewind : () ->
    grtb.current = grtb.ul.children('li').eq(0)
    grtb.show()
    return false

  select : (n) -> # n-th .requirement in currently active tab/pane, 0 < n < 10
    active = grtb.ul.next().children('.active').eq(0)
    target = active.children('.requirement').eq(n)
    return true if target.length is 0
    target.click()
    return true

}

jQuery ->

  # This script file is called only for roles that can grade => roles that 
  # that can see _grd-abacus. Hence, its safe to assume that #form-feedback is visible

  unless grtb.ul?
    grtb.ul = $('#form-feedback').find('ul.nav-tabs').eq(0)
    grtb.current = grtb.ul.children('li').eq(0)
    grtb.root = grtb.ul.parent()
    grtb.form = grtb.root.parent()

  #####################################################################
  ## Enable / disable keyboard shortcuts 
  #####################################################################

  $('#tab-grd-ws, #tab-grd-page').on 'shown', (event) ->
    grtb.keyboard = false
    return true

  $('#tab-grd-panel').on 'shown', (event) ->
    grtb.keyboard = true
    return true

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
        grtb.current = grtb.current.next()
        grtb.show()
    return true

  grtb.form.submit (event) ->
    id = abacus.current.response.attr 'marker'
    clicks = canvas.decompile()
    action = "submit/fdb.json?id=#{id}&clicks=#{clicks}"
    $(this).attr 'action', action
    return true


  #####################################################################
  ## On successful submission of feedback 
  #####################################################################

  grtb.form.ajaxComplete (event, xhr,settings) ->
    url = settings.url
    matched = true

    if url.match(/submit\/fdb/)
      abacus.next.response()
      grtb.rewind()
    else
      matched = false

    event.stopPropagation() if matched is true
    return true

  #####################################################################
  ## Keyboard shortcuts to speeden grading
  #####################################################################

  $('body').on 'keypress', (event) ->
    return true unless grtb.keyboard

    lp = $('#left').children('#left-4').eq(0)
    if lp.hasClass 'hide'
      grtb.keyboard = false
      return true
    pane = lp.children().eq(1).children('#pane-grd-panel').eq(0)
    unless pane.hasClass 'active'
      grtb.keyboard = false
      return true

    key = event.which

    unless (key < 49 || key > 57)
      grtb.select( key - 49 )
    else if key is 115
      grtb.form.submit() if grtb.current.next().length is 0
    return true

