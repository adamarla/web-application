
window.tutorial = {
  list : [],
  root : null,
  current : null,
  active : false,

  options : {
    defaults : {
      'tipLocation' : 'right',
      'nubPosition' : 'left',
      'scroll' : false,
      'nextButton' : false,
      'timer' : 0,
      'postRideCallback' : () ->
        last = tutorial.root.children('ol').filter("[id=#{tutorial.current}]")[0]
        $(last).joyride 'destroy'
        tutorial.current = null
        $(m).removeClass('disabled') for m in $('#control-panel').find('a.dropdown-toggle')
        tutorial.active = false unless last.dataset.onwards is 'true'
        return true
    },

    specificTo : {
      'qzb-milestone-7' : {
        'startTimerOnClick' : false,
        'timer' : 14000
      }
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
      else if tutorial.active
        tutorial.deactivateControlPanel()
        $("##{tutorial.current}").joyride('restart')
        return true

    tutorial.current = n
    tutorial.deactivateControlPanel()
    consolidated = $.extend {}, tutorial.options.defaults

    if tutorial.options.specificTo[n]?
      consolidated = $.extend consolidated, tutorial.options.specificTo[n]

    obj = $("##{tutorial.current}")[0]
    walkThru = $(obj).joyride 'init', consolidated
    $(obj).joyride 'show', walkThru
    return true

  initialize : () ->
    tutorial.root = $('#tutorials') unless tutorial.root?
    tutorial.list.length = 0
    tutorial.list.push($(m).attr('id')) for m in tutorial.root.children('ol')
    tutorial.current = tutorial.list[0]
    tutorial.active = false
    obj = $("##{tutorial.current}")[0]
    $(obj).joyride 'init', tutorial.options.defaults
    return true
    
}
