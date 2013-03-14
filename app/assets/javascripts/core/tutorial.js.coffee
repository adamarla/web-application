
window.tutorial = {
  list : [],
  root : null,
  current : null,
  active : false,

  options : {
    shared : {
      'tipLocation' : 'right',
      'nubPosition' : 'left',
      'scroll' : false,
      'nextButton' : false,
      'postRideCallback' : () ->
        last = tutorial.root.children('ol').filter("[id=#{tutorial.current}]")[0]
        $(last).joyride 'destroy'
        tutorial.current = null
        $(m).removeClass('disabled') for m in $('#control-panel').find('a.dropdown-toggle')
        tutorial.active = false unless last.dataset.onwards is 'true'
        return true
    }
  },

  deactivateControlPanel : () ->
    obj = $("##{tutorial.current}")[0]
    if tutorial.active
      if obj.dataset.enable?
        toggles = $('#control-panel').find('a.dropdown-toggle')
        for m in toggles
          if $(m).attr('id') isnt obj.dataset.enable then $(m).addClass('disabled') else $(m).removeClass('disabled')
    return true
    

  start : (n = null, preInitilization = false) ->
    return false unless n?
    tutorial.active = not preInitilization

    if tutorial.current?
      if tutorial.current isnt n
        last = tutorial.root.children('ol').filter("[id=#{tutorial.current}]")[0]
        $(last).joyride 'destroy'
      else
        tutorial.deactivateControlPanel()
        $("##{tutorial.current}").joyride('restart')
        return true

    tutorial.current = n
    tutorial.deactivateControlPanel()

    obj = $("##{tutorial.current}")[0]
    $(obj).joyride(tutorial.options.shared)
    return true

  initialize : () ->
    tutorial.root = $('#tutorials') unless tutorial.root?
    tutorial.list.length = 0
    tutorial.list.push($(m).attr('id')) for m in tutorial.root.children('ol')
    tutorial.start tutorial.list[0], true
    return true
    
}
