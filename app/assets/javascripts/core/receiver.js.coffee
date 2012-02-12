
window.gutenberg = {
  serverOptions : {
    local : "http://localhost:8080",
    remote : "http://109.74.201.62:8080"
  },
  server : null
}

jQuery ->
  
  ###
    This next call is unassuming but rather important. We initialize 
    variables within the JS based on the results the servthe server being accessed 
    returns
    The response is captured by #wide-panel below. But it could have been any other 
    DOM element. Its just that at the time of writing, #wide-panel was the only 
    DOM element being referenced in this file
  ###
  $.get 'ping'

  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide-panel').ajaxSuccess (e, xhr, settings) ->
    matched = settings.url.match(/quiz\/candidate_questions/) or
              settings.url.match(/quiz\/preview/) or
              settings.url.match(/question\/preview/) or
              settings.url.match(/ping/)
    return if matched is null

    e.stopImmediatePropagation()
    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'quiz/candidate_questions', 'question/preview'
        preview.loadJson json, 'vault'
      when 'quiz/preview'
        preview.loadJson json, 'atm'
      when 'ping'
        if json.deployment is 'production'
          gutenberg.server = gutenberg.serverOptions.remote
        else
          gutenberg.server = gutenberg.serverOptions.local
