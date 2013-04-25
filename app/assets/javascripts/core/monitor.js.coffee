
window.monitor = {
  # 'quizzes', 'worksheets' are simply arrays of indices
  quizzes : [],
  worksheets : [],
  ticker : null,

  add : (json) ->
    if json.monitor.quiz?
      monitor.quizzes.push json.monitor.quiz
    if json.monitor.worksheet?
      monitor.worksheets.push json.monitor.worksheet

    monitor.start() unless monitor.isEmpty()
    return true

  start : () ->
    return false if monitor.ticker?
    monitor.ticker = window.setInterval () -> monitor.ping(),
    30000
    return true

  stop : () ->
    if monitor.ticker?
      window.clearInterval monitor.ticker
      monitor.ticker = null
    return true

  isEmpty : () ->
    return false if monitor.quizzes.length > 0
    return false if monitor.worksheets.length > 0
    return true

  ping : () ->
    $.get 'ping/queue', { quizzes : monitor.quizzes, worksheets : monitor.worksheets }, (data) -> monitor.update(data),
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

    for type in ['quizzes', 'worksheets']
      list = json[type]
      sthCompiled = sthCompiled or (list.length > 0)
      stub = ul.filter("[class~=#{type}]").eq(0)

      for m in list # m = { :id => ..., :name => ... }
        at = monitor[type].indexOf m.id
        if at isnt -1
          monitor[type].splice(at, 1)
          $("<li>#{m.name}</li>").appendTo(stub)

    monitor.stop() if monitor.isEmpty()

    # Launch notifier
    notifier.show('n-compiled') if sthCompiled
    return true
}
