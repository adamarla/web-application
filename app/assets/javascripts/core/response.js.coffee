
jQuery ->

  ########################################################
  #  SIDE PANEL
  ########################################################

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    url = settings.url
    matched = true
    json = $.parseJSON xhr.responseText

    if url.match(/comments\/for/)
      here = $('#side-panel').children().eq(0).find('.calibrations').eq(0)
      coreUtil.interface.grades.initializePanel here
      coreUtil.interface.grades.summarize json, here
      coreUtil.interface.grades.loadDetails json, here
    else
      matched = false

    e.stopPropagation() if matched is true
    return true
  
  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide').ajaxSuccess (e, xhr, settings) ->
    matched = settings.url.match(/quiz\/preview/) or
              settings.url.match(/question\/preview/)
    return if matched is null

    e.stopImmediatePropagation()
    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'quiz/candidate_questions'
        preview.loadJson json, 'vault'
      when 'question/preview'
        $('#wide-wait').addClass 'hide'
        $('#wide-X').removeClass 'hide'
        preview.loadJson json, 'vault'
        ###
          When tagging questions, load any prior info about the question's 
          difficulty and availability onto the <select>s in #misc-traits
        ###

        ###
        misc = $('#side-panel').find '#misc-traits'
        if misc.length isnt 0
          restricted = misc.find '#misc_restricted'
          restricted.val json.preview.restricted unless not restricted?
          diff = misc.find '#misc_difficulty'
          diff.val json.preview.difficulty unless not diff?
        ###
      when 'quiz/preview'
        preview.loadJson json, 'atm'
    return true
  
  $('#embedded-video').ajaxSuccess (e,xhr,settings) ->
    url = settings.url

    if url.match(/video\/load/) isnt null
      e.stopImmediatePropagation()
      json = $.parseJSON xhr.responseText
      $(this).empty() # clear any previous video
      $(json[0].video.url).appendTo $(this)
      return true

