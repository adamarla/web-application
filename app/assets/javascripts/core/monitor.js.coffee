
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
    5000
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
    $.get 'ping/queue', { quizzes : monitor.quizzes }, (data) -> monitor.update(data),
    'json'
    return true

  update : (json) ->
    # Remove IDs from monitor.quizzes
    # We can afford to use an inefficient algo because the arrays 
    # in question will never get too large ( < 5 elements )

    for m in json.compiled
      if monitor.quizzes.indexOf(m.id) isnt -1
        remaining = []
        for j in monitor.quizzes
          remaining.push(j) if j isnt m.id
        monitor.quizzes.length = 0  # clear 
        monitor.quizzes = remaining.slice(0) # copy everything other than just compiled quiz

    monitor.stop() if monitor.isEmpty()

    # Launch notifier
    if json.compiled.length > 0
      target = $('#n-quiz-compiled')
      ul = target.children('ul').eq(0)
      ul.empty()

      for m in json.compiled
        $("<li>#{m.name}</li>").appendTo ul
      notifier.show 'n-quiz-compiled'

    return true
}
