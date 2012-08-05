
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
  blockKeyPress: false,

  initialize : (root) ->
    root = if typeof root is 'string' then $(root) else root
    return false if not root.hasClass 'flipchart'

    nav = root.children('ul').eq(0)
    nTabs = nav.children('li').length
    if (nTabs > 3)
      nav.children('li').eq(j).addClass('hidden') for j in [3...nTabs]

    root.tabs({
      selected : 0,
      show : (event, ui) ->
        last = $(this).tabs 'length'
        next = ui.index + 1
        return if next is last
        $(this).tabs 'option', 'disabled', [next...last] unless $(this).hasClass 'all-active'

      select: (event, ui) ->
        current = ui.index
        last = $(this).tabs('length') - 1

        if current is 0
          show = [0..2]
          disable = [1..2]
        else if current is last
          show = [current-2..current]
          disable = []
        else
          show = [current-1..current+1]
          disable = [current + 1..last]

        #alert "#{current} --> #{show}"

        $(this).tabs 'option', 'disabled', disable unless $(this).hasClass 'all-active'
        tabs = $(this).children('ul').eq(0).children('li')

        for j in [0..last]
          at = show.indexOf j
          #alert "#{j} --> #{at}"
          if at isnt -1
            tabs.eq(j).removeClass 'hidden'
          else
            tabs.eq(j).addClass 'hidden'
    })
    return true

  rewind: (root) ->
    root = if typeof root is 'string' then $(root) else root
    return false if not root.hasClass 'flipchart'

    root.tabs 'enable', 0
    root.tabs 'select', 0
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

  enableAll : (root) ->
    root = if typeof root is 'string' then $(root) else root
    return false if not root.hasClass 'flipchart'

    last = root.tabs 'length'
    root.tabs 'option', 'disabled', []
    return true

  ###
  resetNext : (root) ->
    root = if typeof root is 'string' then $(root) else root
    return false if not root.hasClass 'flipchart'

    next = root.tabs('option', 'selected') + 1
    last = root.tabs 'length'
    return if next is last
  ###

  tabsList: (obj) ->
    chart = obj.closest '.flipchart'
    return null if chart.length is 0
    return chart.children('ul').eq(0)

  containingTab: (obj) ->
    chart = obj.closest '.flipchart'
    return null if chart.length is 0

    panel = obj.closest '.ui-tabs-panel'
    return null if panel.length is 0

    id = panel.attr 'id'
    tab = chart.find("ul > li > a[href='##{id}']").eq(0).closest('li')
    return tab

    
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
      tab = flipchart.containingTab $(this)
      tab.attr 'marker', marker
    else
      event.stopPropagation()

    current = chart.tabs 'option', 'selected'
    chart.attr 'marker', marker if current is 0
    flipchart.next chart unless $(this).hasClass 'accordion-heading' # let the accordion expand
    #flipchart.resetNext chart

    return true
