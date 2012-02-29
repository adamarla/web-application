
jQuery ->

  ########################################################
  #  SIDE PANEL
  ########################################################

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->

    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    # Remove any prior error messages - unconditionally. You know
    # by now that you're going to be updating this panel
    $(this).find('.inline-error').remove()

    if url.match(/teacher\/coverage/)
      here = $('#quiz-builder-form').find '.search-results:first'
      here.empty()

      coreUtil.mnmlists.redistribute json.verticals
      coreUtil.mnmlists.customize 'vertical', {}
      coreUtil.mnmlists.customize 'micro', {checkbox:true}

      results = coreUtil.mnmlists.asAccordion 'selected'
      results.appendTo here
      results.accordion({ header : '.accordion-heading', collapsible:true, active:false })
    else if url.match(/quizzes\/list/)
      here = $('#past-quizzes')
      here.empty()
      list = coreUtil.accordion.build json.quizzes, 'quiz', 'testpapers', 'testpaper', ['quiz-download']
      list.appendTo here
      list.accordion({ header : '.accordion-heading', collapsible:true, active:false })
    else if url.match(/teachers\/roster/)
      here = $('#sektion-list')
      coreUtil.interface.displayJson json.sektions, here, 'sektion', {radio:true}
    else if url.match(/sektions\/students/)
      here = $('#student-list')
      coreUtil.interface.displayJson json.students, here, 'student', {checkbox:true}
    else if url.match(/teacher\/courses/)
      here = $('#courses-taught')
      coreUtil.interface.displayJson json.courses, here, 'course', {radio:true}
    else if url.match(/course\/verticals/)
      here = $('#vertical-selection-list > form:first > .form-fields')
      coreUtil.interface.displayJson json.verticals, here, 'vertical', {checkbox:true}
    else if url.match(/course\/applicable_micros/)
      flipchart.next '#build-quiz'
      here = $('#topic-selection-list > form:first > .form-fields')
      coreUtil.interface.displayJson json.micros, here, 'micro', {checkbox:true}
    else if url.match(/course\/questions/)
      flipchart.next '#build-quiz'
      here = $('#question-options > form:first > .form-fields')
      coreUtil.interface.displayJson json.questions, here, 'question', {checkbox:true}
      preview.loadJson json, 'vault'
    else
      matched = false

    e.stopPropagation() if matched is true

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

