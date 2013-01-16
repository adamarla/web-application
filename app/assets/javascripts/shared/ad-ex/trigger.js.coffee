

window.qtagger = {
  enable : (subpart, state) ->
    return false unless subpart.hasClass('subpart-tagging')
    if state then subpart.removeClass('hide') else subpart.addClass('hide')
    disable = not state
    $(m).prop('disabled', disable) for m in subpart.find('select')
    return true
}

jQuery ->
  
  $('#pane-vertical-topics').on 'click', '.single-line', (event) ->
    # pane-vertical-topics is the the .tab-pane for a left-tab that in 
    # turn is rendered within a regular, horizontal tab

    # In this specific case, we want the marker to be set on the 
    # containing - horizontal - li too 
    $('#tab-tag-topic').parent().attr 'marker', $(this).attr('marker')
    karo.tab.enable 'tab-tag-misc'
    return true

  ###
    Hide/unhide rows in .subpart-tagging
  ###
  $('#tag-misc-properties > form #num-subparts').change (event) ->
    event.stopPropagation()
    show = parseInt($(this).children('option[selected]').eq(0).attr 'value')
    form = $(this).closest('form')
   
    subparts = form.children('.subpart-tagging')
    qtagger.enable($(m), false) for m in subparts
    qtagger.enable(subparts.eq(j), true) for j in [0...show]
    return true

  $('#tab-tag-misc').on 'shown', (event) ->
    event.stopPropagation()
    pane = $( $(this).attr 'href' )
    form = pane.find('form').eq(0)
    qtagger.enable( $(m),false) for m in form.children('.subpart-tagging')
    form.find('#num-subparts option:first').prop 'selected', true
    return true
