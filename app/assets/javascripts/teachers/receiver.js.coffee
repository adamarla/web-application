
jQuery ->

  ########################################################
  #  SIDE PANEL
  ########################################################

  $('#lp').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    # Remove any prior error messages - unconditionally. You know
    # by now that you're going to be updating this panel
    $(this).find('.inline-error').remove()

    ###
    if url.match(/quizzes\/list/)
      here = $('#lp-quizzes')
      here.empty()
      here.addClass 'show'
      for m in json.quizzes
        quiz = m.quiz
        line.write here, quiz, '#per-quiz'
      pgn = $('#lp-paginator')
      pagination.enable pgn, json.last_pg
      pagination.url.set pgn, 'quizzes/list'
      here.children('.single-line').eq(0).click()
    ###
    if url.match(/quiz\/testpapers/)
      here = $('#past-quizzes-list')
      scroll.loadJson json.testpapers, 'testpaper', here, scroll.having.link | scroll.having.nolabel

      # Change the href on the <a> to point to PDFs in atm/
      for a in here.find 'a'
        key = $(a).attr 'parent'
        id = $(a).attr 'marker'
        pId = $(a).attr 'p_id'

        continue if not key? or not id? or not pId?
        $(a).attr 'href', "#{gutenberg.server}/atm/#{key}/#{id}/downloads/assignment-#{pId}-#{id}.pdf"

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
      scroll.loadJson json.students, 'student', here
      here.accordion scroll.options
    else if url.match(/teacher\/courses/)
      here = $('#courses-taught')
      coreUtil.interface.displayJson json.courses, here, 'course', {radio:true}
    else if url.match(/course\/topics_in/)
      here = $('#topic-selection-list > form:first > .form-fields')
      scroll.loadJson json.topics, 'topic', here
    else if url.match(/course\/questions/)
      variables.testpaper.reset()
      flipchart.next '#build-quiz'
      here = $('#question-options > form:first > .form-fields')
      scroll.initialize json.topics, 'topic', here
      here.accordion scroll.options
      scroll.loadJson json.questions, 'question', here, scroll.having.check | scroll.having.button
      preview.loadJson json, 'vault'

      # Set the # of likeys and span on each question 
      for q in json.questions
        m = q.question
        id = m.id
        k = here.find ".swiss-knife[marker=#{id}]:first"
        continue if not k?
        k.attr 'span', m.span
        nLiked = m.liked
        continue if nLiked is 0
        b = k.children 'input[type="button"]'
        b.val "#{nLiked}"

      # Mark the questions that have been liked by the teacher in the past 
      for f in json.favourites
        q = here.find ".swiss-knife[marker=#{f}]:first"
        continue if not q?
        b = q.children 'input[type="button"]'
        b.attr 'liked', true
    else if url.match(/teacher\/testpapers/)
      here = $('#testpaper')
      coreUtil.interface.displayJson json.testpapers, here, 'testpaper', {radio:true}
      # first = here.children('.swiss-knife').eq(0)
      # first.children("input[type='radio']").eq(0).trigger 'click' if first? # auto-load report-card for latest test
    else if url.match(/student\/responses/)
      coreUtil.interface.displayJson json.preview.questions, "#preview", 'question', {}
      reportCard.overview json.preview.questions, "#overview", 'question'
      preview.loadJson json, 'locker'
      first = $('#overview').children('.swiss-knife').eq(0)
      first.trigger 'click' unless first.length is 0
    else if url.match(/teacher\/topics_this_section/)
      here = $('#deep-dive-topic')
      coreUtil.interface.displayJson json.topics, here, 'topic'
    else if url.match(/sektion\/proficiency/)
      $('#flot-chart').addClass 'hide-y'
      chart.initialize()

      chart.series.define json.students, 'student', 'relative', 'y' # n = 0
      chart.series.define json.students, 'student', 'benchmark', 'y' # n = 1
      chart.series.define json.students, 'student', 'db', 'y' # n = 2

      middle = if json.students[0].student.db < json.students[0].student.benchmark then 2 else 1
      chart.series.link 0, middle # n = 3
      
      chart.series.customize 0, {
        color: color.blue,
        points : { show:true, radius: 5, fill: 0},
        label: "Student Proficiency"
      }
      chart.series.customize 1, {
        color: color.green,
        points: { show: true, radius: 2, fill: true, fillColor: color.green },
        label: "Your Benchmark"
      }
      chart.series.customize 2, {
        color: color.orange,
        points: { show: true, radius: 2, fill: true, fillColor: color.orange },
        label: "Expected Proficiency (Avg)"
      }
      chart.series.customize 3, { color: color.blue, lines: { show: true, lineWidth: 1 } }

      chart.draw {
        xaxis : { min: 0, max: 6, position: "top"},
        yaxis: { ticks: [] },
        legend: { show: true, position:"ne", backgroundColor: "transparent" }
      }
      chart.series.label 0, json.students, 'student'
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
    else if url.match(/preview\/calibrations/)
      preview.loadJson json, 'calibrations'
    else if url.match(/disputed/)
      here = $('#disputes')
      scroll.initialize json.quizzes, 'quiz', here
      scroll.loadJson json.disputed, 'disputed', here, scroll.having.numeric | scroll.having.constant
      here.accordion scroll.options
      # coreUtil.interface.displayJson json.disputed, here, 'disputed', {radio:false, numeric:true, constant:true}
      preview.loadJson json, 'locker', true
    else
      matched = false

    e.stopPropagation() if matched is true
    return true
