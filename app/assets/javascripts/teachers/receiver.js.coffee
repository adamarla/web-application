
jQuery ->

  ########################################################
  #  SIDE PANEL
  ########################################################

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teacher\/coverage/) or
              settings.url.match(/quizzes\/list/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    # Remove any prior error messages - unconditionally. You know
    # by now that you're going to be updating this panel
    $(this).find('.inline-error').remove()
    switch matched.pop()
      when 'teacher/coverage'
        here = $('#quiz-builder-form').find '.search-results:first'
        here.empty()

        coreUtil.mnmlists.redistribute json.macros
        coreUtil.mnmlists.customize 'macro', {}
        coreUtil.mnmlists.customize 'micro', {checkbox:true}

        results = coreUtil.mnmlists.asAccordion 'selected'
        results.appendTo here
        results.accordion({ header : '.accordion-heading', collapsible:true, active:false })
      when 'quizzes/list'
        here = $('#quizzes-summary')
        coreUtil.interface.displayJson json.quizzes, here, 'quiz', {radio:true, button:true}
        swissKnife.setButtonCaption here, 'preview'

  .ajaxError (e,xhr,settings) ->
    matched = settings.url.match(/teacher\/coverage/)
    return if matched is null

    # Remove any prior error messages and search-results - unconditionally. 
    # You know by now that there has been an error !
    $(this).find('.search-results').empty()
    $(this).find('.inline-error').remove()

    switch matched.pop()
      when 'teacher/coverage'
        here = $('#quiz-builder-form')
        coreUtil.messaging.inlineError here, 'we apologize ...', "the requisite course isn't currently present in our database"

  ########################################################
  #  MIDDLE PANEL
  ########################################################

  $('#middle-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teachers\/roster/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'teachers/roster'
        here = $('#teacher-roster')
        coreUtil.interface.displayJson json.sections, here, 'section', {radio:true}

    return true

  ########################################################
  #  RIGHT PANEL
  ########################################################

  $('#right-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/study_groups\/students/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'study_groups/students'
        here = $('#enrolled-student-list > form')
        coreUtil.interface.displayJson json.students, here, 'student', {checkbox:true}

    return true

  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide-panel').ajaxSuccess (e, xhr, settings) ->
    matched = settings.url.match(/quiz\/candidate_questions/) or
              settings.url.match(/quiz\/preview/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'quiz/candidate_questions'
        preview.loadJson json.candidates, 'candidate'
      when 'quiz/preview'
        preview.loadJson json.questions, 'question'
