
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
      coreUtil.mnmlists.customize 'topic', {checkbox:true}

      results = coreUtil.mnmlists.asAccordion 'selected'
      results.appendTo here
      results.accordion({ header : '.accordion-heading', collapsible:true, active:false })
    else if url.match(/quizzes\/list/)
      here = $('#past-quizzes')
      here.empty()
      list = coreUtil.accordion.build json.quizzes, 'quiz', 'testpapers', 'testpaper', ['quiz-download']
      list.appendTo here
      list.accordion({ header : '.accordion-heading', collapsible:true, active:false })
      here.find('.accordion-heading').eq(0).click() # open preview for the first quiz automatically
    else if url.match(/teachers\/roster/)
      child = $('#side-panel').children().eq(0).attr 'id'
      if child is 'deep-dive'
        here = $('#deep-dive-section')
      else
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
    else if url.match(/course\/applicable_topics/)
      flipchart.next '#build-quiz'
      here = $('#topic-selection-list > form:first > .form-fields')
      coreUtil.interface.displayJson json.topics, here, 'topic', {checkbox:true}
    else if url.match(/course\/questions/)
      flipchart.next '#build-quiz'
      here = $('#question-options > form:first > .form-fields')
      coreUtil.interface.displayJson json.questions, here, 'question', {checkbox:true}
      preview.loadJson json, 'vault'
    else if url.match(/quiz\/assign/) || url.match(/teacher\/build_quiz/)
      at = json.at
      hours = Math.floor(at/60)
      minutes = (at % 60)
      minutes = if minutes < 10 then "0#{minutes}" else "#{minutes}"
      eet = "#{hours}h:#{minutes}min" # about a minute per document

      if url.match(/teacher\/build_quiz/) then g = $('#build-quiz-receipt') else g = $('#assign-quiz-receipt')

      g.find('#job-position:first').children('.ticker-display-value').text "##{at}"
      g.find('#job-eta:first').children('.ticker-display-value').text "#{eet}"

      return true

    else if url.match(/teacher\/testpapers/)
      here = $('#testpaper')
      coreUtil.interface.displayJson json.testpapers, here, 'testpaper', {radio:true}
    else if url.match(/testpaper\/summary/)
      here = $('#student')
      coreUtil.interface.displayJson json.students, here, 'student', {radio:true}
      reportCard.overview json.students, here, 'student'

      graph.initialize()
      graph.loadJson json.students, 'student', 'name', graph.filter.notZero, 'graded_thus_far'
      graph.draw [json.mean], false

    else if url.match(/student\/responses/)
      coreUtil.interface.displayJson json.preview.questions, "#preview", 'question', {}
      reportCard.overview json.preview.questions, "#preview", 'question'
      preview.loadJson json, 'locker'
    else if url.match(/teacher\/topics_this_section/)
      here = $('#deep-dive-topic')
      coreUtil.interface.displayJson json.topics, here, 'topic'
    else if url.match(/sektion\/proficiency/)
      graph.initialize()
      graph.loadJson json.students, 'student', 'name', graph.filter.notZero, 'x'
      options = $.extend {}, graph.options, { xaxis: { position: "top", min:1,
      max:3,
      ticks : [[1, "Revisit Topic >"],
               [1.5, "Brush-up on basics >"],
               [2, "Needs practice >"],
               [2.5, "Doing well >"],
               [3, "Teacher?"]
              ] }
      }
      graph.draw [], true, options
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

