
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

    if url.match(/quizzes\/list/)
      here = $('#past-quizzes-list')
      scroll.initialize json.quizzes, 'quiz', here
      here.accordion scroll.options
    else if url.match(/quiz\/testpapers/)
      here = $('#past-quizzes-list')
      scroll.loadJson json.testpapers, 'testpaper', here, null, scroll.having.link

      # Change the href on the <a> to point to PDFs in atm/
      for a in here.find 'a'
        key = $(a).attr 'parent'
        id = $(a).attr 'marker'
        pId = $(a).attr 'p_id'

        continue if not key? or not id? or not pId?
        $(a).attr 'href', "#{gutenberg.server}/atm/#{key}/#{id}/downloads/assignment-#{pId}-#{id}.pdf"

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
      here = $('#topic-selection-list > form:first > .form-fields')
      scroll.initialize json.verticals, 'vertical', here
      here.accordion scroll.options
    else if url.match(/course\/topics_in/)
      here = $('#topic-selection-list > form:first > .form-fields')
      scroll.loadJson json.topics, 'topic', here
    else if url.match(/course\/questions/)
      flipchart.next '#build-quiz'
      here = $('#question-options > form:first > .form-fields')
      scroll.initialize json.topics, 'topic', here
      here.accordion scroll.options
      scroll.loadJson json.questions, 'question', here, 'marks', scroll.having.check_btn
      preview.loadJson json, 'vault'

      # Mark the questions that have been favourited by the teacher in the past 
      for f in json.favourites
        q = here.find ".swiss-knife[marker=#{f}]:first"
        continue if not q?
        b = q.children 'input[type="button"]'
        b.attr 'favourited', true
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
    return true
