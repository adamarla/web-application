
window.monitor = {
  # 'quizzes', 'exams' are simply arrays of indices
  quizzes : [],
  exams : [],
  ticker : null,
  immediate : false, 

  bell : {
    obj : null, 
    ticker : null,
    nPings : 0,

    start : () ->
      return false if monitor.bell.ticker?
      monitor.bell.obj = $('#lnk-bell')[0] unless monitor.bell.obj?  
      monitor.bell.ticker = window.setInterval () -> monitor.bell.ping(),
      1000
      return true

    stop : () ->
      if monitor.bell.ticker?
        window.clearInterval monitor.bell.ticker
        monitor.bell.ticker = null
      $(monitor.bell.obj).removeClass('on')
      monitor.bell.nPings = 0
      return true

    ping : () ->
      b = $(monitor.bell.obj)
      if b.hasClass('on')
        b.removeClass('on') 
        monitor.bell.nPings += 1
      else 
        b.addClass('on') 
      monitor.bell.stop() if monitor.bell.nPings > 7
      return true

    update : (json) ->
      mn = $('#m-bell')
      for type in ['quizzes', 'exams']
        continue unless json[type]?

        for j in json[type]
          at = monitor[type].indexOf j.id
          # alert "#{monitor[type]} --> #{at}"
          if at isnt -1
            monitor[type].splice(at, 1) # remove the id for further monitoring
            monitor.bell.start()
            # Add download path to $('#m-bell')
            html = $("<li><a href='#{j.path}'>#{j.name}</a></li>")
            html.appendTo mn
      return true
  }

  add : (json, immediate = false) ->
    list = json.monitor
    return false unless list?

    # Both list.quiz and list.exam are arrays 
    if list.quiz? 
      monitor.quizzes.push(i) for i in list.quiz if list.quiz.length > 0
    if list.exam?
      monitor.exams.push(i) for i in list.exam if list.exam.length > 0

    monitor.start(immediate) unless monitor.isEmpty()
    return true

  start : (immediate = false) ->
    return false if monitor.ticker?

    monitor.immediate = immediate
    unless monitor.immediate 
      monitor.ticker = window.setInterval () -> monitor.ping(),
      30000
    else
      monitor.ticker = window.setTimeout(monitor.ping, 1000)
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

  ping : (immediate = false) ->
    $.get 'ping/queue', { 'quizzes[]' : monitor.quizzes, 'exams[]' : monitor.exams }, (data) -> monitor.update(data),
    'json'
    if monitor.immediate
      window.clearTimeout monitor.ticker
      monitor.ticker = null
      monitor.start() unless monitor.isEmpty() # revert to polling every 30 seconds
    return true

  update : (json, fn = monitor.bell.update) ->
    fn(json) if fn?
    monitor.stop() if monitor.isEmpty()
    return true

} # of file 
