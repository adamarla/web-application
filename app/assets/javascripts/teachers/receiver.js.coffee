
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
      scroll.loadJson json.testpapers, 'testpaper', here, 'ticker', scroll.having.link | scroll.having.nolabel

      # Change the href on the <a> to point to PDFs in atm/
      for a in here.find 'a'
        key = $(a).attr 'parent'
        id = $(a).attr 'marker'
        pId = $(a).attr 'p_id'

        continue if not key? or not id? or not pId?
        $(a).attr 'href', "#{gutenberg.server}/atm/#{key}/#{id}/downloads/assignment-#{pId}-#{id}.pdf"

    else if url.match(/teacher\/sektions/)
      child = $('#side-panel').children().eq(0).attr 'id'
      switch child
        when 'deep-dive' then here = $('#deep-dive-section')
        when 'quizzes-summary' then here = $('#sektion-list')
        when 'sektions-summary' then here = $('#all-my-sektions')
        else here = null
      coreUtil.interface.displayJson json.sektions, here, 'sektion', {radio:true, link:true} unless here is null

      # Edit the <a> in the swiss-knives to point to downloadble list of student names
      for m in json.sektions
        r = m.sektion
        sk = here.find ".swiss-knife[marker=#{r.id}]"
        continue if sk.length is 0

        a = sk.children('a').eq(0)
        a.text 'download list'
        a.attr 'href', "#{gutenberg.server}/front-desk/schools/#{r.lookin}/#{r.lookfor}.pdf"
    else if url.match(/sektion\.json/)
      if json.sektion? # same URL for create & update actions, but different JSON responses 
        item = swissKnife.forge json, 'sektion', {radio:true}, 'ticker'
        item.prependTo('#all-my-sektions').hide().fadeIn('slow')
      else matched = false # so that event can propogate and update button text cna revert  
    else if url.match(/teacher\/students_with_names/)
      here = $('#enrolled-students')
      scroll.overlayJson json.students, 'student', here, '.swiss-knife', "hide"
    else if url.match(/teacher\/students/)
      here = $('#enrolled-students')
      scroll.loadJson json.students, 'student', here, 'login'
      here.accordion scroll.options
    else if url.match(/sektion\/students/)
      child = $('#side-panel').children().eq(0).attr 'id'
      switch child
        when 'sektions-summary'
          here = $('#enrolled-students')
          scroll.overlayJson json.students, 'student', here, '.swiss-knife', "nop", "check"
        else
          here = $('#student-list')
          coreUtil.interface.displayJson json.students, here, 'student', {checkbox:true}, true, 'login'
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
      scroll.loadJson json.questions, 'question', here, 'marks', scroll.having.check | scroll.having.button
      preview.loadJson json, 'vault'

      # Set the # of likeys on each question 
      for q in json.questions
        m = q.question
        nLiked = m.liked
        continue if nLiked is 0
        id = m.id
        k = here.find ".swiss-knife[marker=#{id}]:first"
        continue if not k?
        b = k.children 'input[type="button"]'
        b.val "#{nLiked}"

      # Mark the questions that have been liked by the teacher in the past 
      for f in json.favourites
        q = here.find ".swiss-knife[marker=#{f}]:first"
        continue if not q?
        b = q.children 'input[type="button"]'
        b.attr 'liked', true
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
      reportCard.overview json.preview.questions, "#overview", 'question'
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
    else if url.match(/teacher\/suggested_questions/)
      here = $('#typeset-for-me')
      coreUtil.interface.displayJson json.typesets, here, 'typeset', {radio:false}
      preview.loadJson json, 'vault'
    else if url.match(/load\/grades/)
      here = $('#calibrations')
      existing = here.find "input[type='text']"

      # JSON = { grades: [{ grade : {calibration_id:xyz, marks:abc } }, .... ] }
      for m in json.grades
        r = m.grade
        continue unless r.calibration_id?
        target = existing.filter("[marker=#{r.calibration_id}]").eq(0)
        continue unless target?
        target.val r.marks
    else
      matched = false

    e.stopPropagation() if matched is true
    return true
