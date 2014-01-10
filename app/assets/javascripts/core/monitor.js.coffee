
window.monitor = {
  # 'quizzes', 'exams' are simply arrays of indices
  quizzes : [],
  exams : [],
  ticker : null,

  add : (json) ->
    trackObjs = json.monitor
    return false unless trackObjs?

    if trackObjs.quiz?
      monitor.quizzes.push trackObjs.quiz
    if trackObjs.exam?
      monitor.exams.push trackObjs.exam

    monitor.start() unless monitor.isEmpty()
    return true

  start : () ->
    return false if monitor.ticker?
    monitor.ticker = window.setInterval () -> monitor.ping(),
    15000
    return true

  stop : () ->
    if monitor.ticker?
      window.clearInterval monitor.ticker
      monitor.ticker = null
    return true

  isEmpty : () ->
    return false if monitor.quizzes.length > 0
    return false if monitor.exams.length > 0
    return true

  ping : () ->
    $.get 'ping/queue', { quizzes : monitor.quizzes, exams : monitor.exams }, (data) -> monitor.update(data),
    'json'
    return true

  update : (json) ->
    # Remove IDs from monitor.quizzes
    # We can afford to use an inefficient algo because the arrays 
    # in question will never get too large ( < 5 elements )
    
    target = $('#n-compiled')
    ul = target.find('ul')
    $(m).empty() for m in ul

    sthCompiled = false
    for type in ['quizzes', 'exams']
      list = json[type]
      continue unless list?

      sthCompiled = sthCompiled or (list.length > 0)
      stub = ul.filter("[class~=#{type}]").eq(0)
      
      for m in list # m = { :id => ..., :name => ... }
        at = monitor[type].indexOf m.id
        if at isnt -1
          monitor[type].splice(at, 1)
          $("<li>#{m.name}</li>").appendTo(stub)

    monitor.stop() if monitor.isEmpty()
    # update the demo if some of these quizzes are the pre-fab kind
    demo.update json.demo

    # Launch notifier
    # notifier.show('n-compiled') if sthCompiled
    return true
}
