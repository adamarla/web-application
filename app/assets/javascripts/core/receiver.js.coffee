
jQuery ->

  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide-panel').ajaxSuccess (e, xhr, settings) ->
    matched = settings.url.match(/quiz\/candidate_questions/) or
              settings.url.match(/quiz\/preview/) or
              settings.url.match(/question\/preview/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'quiz/candidate_questions', 'question/preview'
        preview.loadJson json, 'vault'
      when 'quiz/preview'
        preview.loadJson json, 'atm'
