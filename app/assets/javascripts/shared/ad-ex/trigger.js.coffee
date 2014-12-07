

window.qtagger = {
  enable : (subpart, state) ->
    return false unless subpart.hasClass('subpart-tagging')
    if state then subpart.removeClass('hide') else subpart.addClass('hide')
    disable = not state
    $(m).prop('disabled', disable) for m in subpart.find('select')
    return true
}

previewSg = (json) ->
  active = $('#sg-ongoing').find('.in').eq(0)
  inner = active.children().eq(0)
  lines.columnify inner, json.slots
  return true

jQuery ->

  upload.button.add('btn-upload-solution', "#{gutenberg.server}/Upload/scan", 'tab-doubts-1', { type: 'SOLN', student_id: 0, vers: 0 })
  tagger.add $('#i-doubt-tags')[0]

  # REVIEW AND DELETE CODE BELOW !!!! 
  
  $('#pane-vertical-topics').on 'click', '.line', (event) ->
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

  ###
    Ongoing suggestion accordion: Opening should load list of slots. 
    Closing should empty out the .accordion-inner
  ###

  $('#sg-ongoing').on 'shown', () ->
    active = $(this).find('.in').eq(0)
    marker = active.prev().attr('marker')
    # alert "Showing #{marker}"
    karo.ajaxCall "suggestion/preview?id=#{marker}", previewSg
    return true

  $('#sg-ongoing').on 'hide', () ->
    active = $(this).find('.in').eq(0)
    marker = active.prev().attr('marker')
    inner = active.children().eq(0)
    inner.empty()
    # alert "Hiding #{marker}"
    return true

  $('#btn-audit-allok').on 'click', (event) ->
    form = $('#m-audit-form').find('form').eq(0)
    $(m).prop('checked', false) for m in form.find("input[type='checkbox']")
    form.find("textarea").eq(0).val null
    return true

  $('#apprentice-gating').on 'click', 'input[type=checkbox]', (event) ->
    event.stopImmediatePropagation()
    allGating = $(this).parent().parent().find "input[type='checkbox']"
    gating = false
    
    for m in allGating 
      gating |= $(m).prop('checked')
      break if gating 

    form = $(this).closest('form')
    submitBtn = form.find('button').eq(0)
    if gating then submitBtn.text('Keep Sandboxed') else submitBtn.text('Can go Live')
    return true

