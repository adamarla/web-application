
# JSON is of the form 
# json = { quizzes: [ records ... ], exams: [ records ... ], worksheets: [ records ... ] }
# where each record is of the form 
#    record = { id: a, name: b, path: to_download_pdf }

window.bell = {
  obj : null, 
  pulse : null,
  nPings : 0,

  start : () ->
    return false if bell.pulse?
    bell.obj = $('#lnk-bell')[0] unless bell.obj?  
    bell.pulse = window.setInterval () -> bell.ping(),
    1000
    return true

  stop : () ->
    if bell.pulse?
      window.clearInterval bell.pulse
      bell.pulse = null
    $(bell.obj).removeClass('on')
    bell.nPings = 0
    return true

  ping : () ->
    b = $(bell.obj)
    if b.hasClass('on')
      b.removeClass('on') 
      bell.nPings += 1
    else 
      b.addClass('on') 
    bell.stop() if bell.nPings > 7
    return true

  update : (json) ->
    mn = $('#m-bell')
    for type in ['quizzes', 'exams', 'worksheets']
      continue unless json[type]?

      for j in json[type]
        bell.start()
        # Add download path to $('#m-bell')
        html = $("<li><a href='#{j.path}'>#{j.name}</a></li>")
        html.appendTo mn
    return true
} # of file 
