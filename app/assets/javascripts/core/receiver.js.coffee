
jQuery ->
  
  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide-panel').ajaxSuccess (e, xhr, settings) ->
    matched = settings.url.match(/quiz\/candidate_questions/) or
              settings.url.match(/quiz\/preview/) or
              settings.url.match(/question\/preview/) or
              settings.url.match(/ping/) or
              settings.url.match(/yardsticks\/preview/)
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
      when 'yardsticks/preview'
        preview.loadJson json, 'frontdesk-yardsticks'
    return true
  
  $('#embedded-video').ajaxSuccess (e,xhr,settings) ->
    url = settings.url

    if url.match(/video\/load/) isnt null
      e.stopImmediatePropagation()
      json = $.parseJSON xhr.responseText
      $(this).empty() # clear any previous video
      $(json[0].video.url).appendTo $(this)
      return true

