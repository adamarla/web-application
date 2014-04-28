
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
      'postRideCallback' : (completed = true) ->
        last = tutorial.root.children('ol').filter("[id=#{tutorial.current}]")[0]
        $(last).joyride 'destroy'
        tutorial.current = null
        $(m).removeClass('disabled') for m in $('#control-panel').find('a.dropdown-toggle')

        goOn = last.getAttribute('data-onwards') is 'true'
        tutorial.active = goOn and completed
        return true
    },

    specificTo : {
      'exb-milestone-3' : {
        'startTimerOnClick' : false,
        'timer' : 14000
      },
      'editqz-milestone-2' : {
        'startTimerOnClick' : false,
        'timer' : 7000
      },
      'editqz-milestone-4' : {
        'startTimerOnClick' : false,
        'timer' : 7000
      }
    }
  },

  deactivateControlPanel : () ->
    obj = $("##{tutorial.current}")[0]
    if tutorial.active
      enableLink = obj.getAttribute('data-enable')
      if enableLink?
        toggles = $('#control-panel').find('a.dropdown-toggle')
        for m in toggles
          if $(m).attr('id') isnt enableLink then $(m).addClass('disabled') else $(m).removeClass('disabled')
    return true
    

  start : (n = null) ->
    return false unless n?
    return false unless tutorial.active

    if tutorial.current is n
      tutorial.deactivateControlPanel()
      $("##{tutorial.current}").joyride('restart')
      return true
    else
      last = tutorial.root.children('ol').filter("[id=#{tutorial.current}]")[0]
      $(last).joyride 'destroy'
      tutorial.current = n
      # tutorial.deactivateControlPanel()

      consolidated = {}
      $.extend consolidated, tutorial.options.defaults
      if tutorial.options.specificTo[n]?
        $.extend consolidated, tutorial.options.specificTo[n]
      obj = $("##{tutorial.current}")[0]
      $(obj).joyride('init', consolidated)
      tutorial.start n
    return true

  initialize : () ->
    tutorial.root = $('#tutorials') unless tutorial.root?
    tutorial.list.length = 0
    tutorial.list.push($(m).attr('id')) for m in tutorial.root.children('ol')
    tutorial.current = tutorial.list[0]
    obj = $("##{tutorial.current}")[0]
    $(obj).joyride 'init', tutorial.options.defaults
    return true
    
}
