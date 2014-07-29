
window.monitor = {
  # 'quizzes', 'exams' are simply arrays of indices
  quizzes : [],
  exams : [],
  worksheets : [],
  pulse : null,
  immediate : false, 

  tabs : { 
    list : null,
    active : null,

    start : () -> 
      unless monitor.tabs.list?
        monitor.tabs.list = $("#desktop > .g-panel > :not([class~='paginator']) > ul")
      return true

    refreshSiblingsOf : (tab) -> # tab = <a data-toggle='tab'> 
      hidden = $(tab).closest('div').hasClass 'hide'
      return false if hidden

      uncles = $(tab).parent().siblings('li')
      for j in uncles 
        if $(j).hasClass 'disabled'
          $(k).remove() for k in $(j).find('span.ping')
        else
          pinged = $(j).find('span.ping').length isnt 0
          continue if pinged 
          a = $(j).children('a')[0]
          url = a.getAttribute 'data-url-self'
          
          if url?
            isAtomic = url.indexOf('?') is -1 
            continue unless isAtomic 
            # => url is of the form a/b - not a/b?id=x => query can be made w/o any selection

            $.ajax {
              url: url,
              context: a, # by far, the most important line in this call
              data: { ping: true },
              success: (json) ->
                monitor.tabs.update this, json.ping
            }
      return true 

    update : (tab, value) -> # tab = <a data-toggle='tab'>
      $(m).remove() for m in $(tab).children('span')
      $("<span class='ping'>#{value}</span>").appendTo $(tab)
      return true
  },

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
