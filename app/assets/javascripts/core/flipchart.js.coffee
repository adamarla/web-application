
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

    next = root.children('.ui-tabs-panel').eq(next)
    for type in ['radio', 'checkbox']
      for obj in next.find "input[type=#{type}]"
        $(obj).prop 'checked', false
    return true
    
}

jQuery ->
  
  $('.flipchart').on 'click', 'input[type="radio"], .accordion-heading', (event) ->
    chart = $(this).closest '.flipchart'
    ###
      The first tab is special because it marks the beginning of the 'diving-in'
      process. Whatever is selected in the first tab is, therefore, important 
      and usually the only thing we want to track
    ###
    current = chart.tabs 'option', 'selected'
    chart.attr 'marker', $(this).attr 'marker' if current is 0
    flipchart.next chart unless $(this).hasClass 'accordion-heading' # let the accordion expand
    flipchart.resetNext chart
    event.stopPropagation() # stop unnecessary bubbling up to the containing .panel
    return true
