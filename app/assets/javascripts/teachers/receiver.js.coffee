
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
      eet = (at + 1) * 3 # est = expected end time

      title = $('#queue-status').children('h4:first')
      title.text "Your request is ##{at} in the queue"
      implication = $('#queue-status').children('p:first')
      implication.text "In about #{eet} minutes, your document should be available for download"

      $('#queue-status').dialog('open')
    else if url.match(/teacher\/testpapers/)
      here = $('#testpaper')
      coreUtil.interface.displayJson json.testpapers, here, 'testpaper', {radio:true}
    else if url.match(/testpaper\/summary/)
      here = $('#student')
      coreUtil.interface.displayJson json.students, here, 'student', {radio:true}
      reportCard.overview json.students, here, 'student'

      pts = graphs.getPlotPts json.students, 'student', json.mean, (p) -> p.graded_thus_far > 0
      $.plot $("#flot-chart"), [
        {
          data: pts, lines: {show: true},
          points: {show:true, radius: 6}
        }
      ],
      {
        yaxis: {tickLength: 0 },
        grid: {
          borderWidth: 0,
          aboveData: false
        }
      }
    else if url.match(/student\/responses/)
      coreUtil.interface.displayJson json.preview.questions, "#preview", 'question', {}
      reportCard.overview json.preview.questions, "#preview", 'question'
      preview.loadJson json, 'locker'
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

