
jQuery ->
  
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
