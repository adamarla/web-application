
###
  Flip-charts are for all those times when only one panel is available 
  to show nested data. At such times, one begins with some 'top-level' 
  data and then - depending on some selection in that view - dives 
  down to the next level data - rendered in the same panel 

  The obvious way to achieve this is by using jQuery tabs. Here, we simply
  add elements to its behaviour - like disabling all tabs after the selected one
  and switching to the next one when a selection is made in the current one

###

window.flipchart = {
  initialize : (root) ->
    root = if typeof root is 'string' then $(root) else root
    return false if not root.hasClass 'flipchart'

    root.tabs({
      selected : 0,
      show : (event, ui) ->
        last = $(this).tabs 'length'
        next = ui.index + 1
        return if next is last
        $(this).tabs 'option', 'disabled', [next...last]
    })
    return true

  next : (root) ->
    root = if typeof root is 'string' then $(root) else root
    return false if not root.hasClass 'flipchart'

    next = root.tabs('option', 'selected') + 1
    last = root.tabs 'length'
    return if next is last
    root.tabs 'enable', next
    root.tabs 'select', next
    return true

  resetNext : (root) ->
    root = if typeof root is 'string' then $(root) else root
    return false if not root.hasClass 'flipchart'

    next = root.tabs('option', 'selected') + 1
    last = root.tabs 'length'
    return if next is last

  closestActiveTabTo: (obj) ->
    flipchart = obj.closest '.flipchart'
    return null if flipchart.length is 0
    return flipchart.find('ul > li.ui-tabs-selected').eq(0)

    next = root.children('.ui-tabs-panel').eq(next)
    for type in ['radio', 'checkbox']
      for obj in next.find "input[type=#{type}]"
        $(obj).prop 'checked', false
    return true
    
}

jQuery ->
  
  $('.flipchart').on 'click', 'input[type="radio"], .accordion-heading', (event) ->
    chart = $(this).closest '.flipchart'
    marker = $(this).attr 'marker'

    ###
      Previously, we assumed that a radio button in the first tab was special 
      and only its marker needed to be tracked. This is no longer true. We should
      track the marker for any radio button in any tab. 
      Where should we track it then? On the containing tab! Where else?
    ###

    if $(this).is 'input[type="radio"]'
      tab = flipchart.closestActiveTabTo $(this)
      tab.attr 'marker', marker
    else
      event.stopPropagation()

    current = chart.tabs 'option', 'selected'
    chart.attr 'marker', marker if current is 0
    flipchart.next chart unless $(this).hasClass 'accordion-heading' # let the accordion expand
    flipchart.resetNext chart

    return true
