
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
}

jQuery ->
  
  $('.flipchart').on 'click', 'input[type="radio"]', ->
    chart = $(this).closest '.flipchart'
    flipchart.next chart
    return true
