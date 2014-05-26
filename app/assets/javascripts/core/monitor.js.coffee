
window.monitor = {
  # 'quizzes', 'exams' are simply arrays of indices
  quizzes : [],
  exams : [],
  worksheets : [],
  pulse : null,
  immediate : false, 

  add : (json, immediate = false) ->
    list = json.monitor
    return false unless list?

    for k in ['quizzes', 'exams', 'worksheets'] 
      continue unless list[k]?
      target = monitor[k]
      for i in list[k]
        already = target.indexOf(i) isnt -1
        continue if already 
        target.push i

    monitor.start(immediate) unless monitor.isEmpty()
    return true

  start : (immediate = false) ->
    return false if monitor.pulse?

    monitor.immediate = immediate
    unless monitor.immediate 
      monitor.pulse = window.setInterval () -> monitor.ping(),
      30000
    else
      monitor.pulse = window.setTimeout(monitor.ping, 1000)
    return true

  stop : () ->
    if monitor.pulse?
      window.clearInterval monitor.pulse
      monitor.pulse = null
    return true

  isEmpty : () ->
    return false if monitor.quizzes.length > 0
    return false if monitor.exams.length > 0
    return false if monitor.worksheets.length > 0
    return true

  ping : (immediate = false) ->
    $.get 'ping/queue', 
    { 'quizzes[]' : monitor.quizzes, 'exams[]' : monitor.exams, 'worksheets[]' : monitor.worksheets }, (
    data) -> monitor.update(data),
    'json'

    if monitor.immediate
      window.clearTimeout monitor.pulse
      monitor.pulse = null
      monitor.start() unless monitor.isEmpty() # revert to polling every 30 seconds
    return true

  update : (json) ->
    # Remove compiled object IDs from list of monitored objects
    for type in ['quizzes', 'exams', 'worksheets']
      continue unless json[type]?
      for j in json[type]
        at = monitor[type].indexOf j.id
        monitor[type].splice(at, 1) unless at is -1 # remove the id for further monitoring
    
    monitor.stop() if monitor.isEmpty()
    return true

} # of file 
