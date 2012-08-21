
jQuery ->

  $('#main-links a').click ->
    teacher = $('#control-panel').attr 'marker'
    id = $(this).attr 'id'
    switch id
      when 'quizzes-link'
        $.get 'quizzes/list.json'
        $.get "teacher/sektions.json?id=#{teacher}"
      when 'report-cards-link'
        $.get "teacher/testpapers.json?id=#{teacher}"
      when 'sektions-link'
        $.get "teacher/sektions.json?id=#{teacher}"
        $.get "teacher/students.json?id=#{teacher}&exclusive=no"
    return true

  # Assigning a Quiz to students selected in #student-list
  $('#student-list > form:first').submit ->
    tabs = flipchart.tabsList $(this)

    quizTab = tabs.children('li').eq(0)
    quiz = quizTab.attr 'marker'
    return if not quiz?
    # alert quiz

    coreUtil.forms.modifyAction $(this), "quiz/assign.json?id=#{quiz}", 'put'
    flipchart.next '#quizzes-summary'
    return true

  ###
    On load, auto-click the first main-link > a that has attribute default='true'
  ###
  $('#main-links a[default="true"]:first').click()

  ###
    If an accordion is rendered within a flipchart page, then opening the 
    accordion by clicking on an accordion-header should enable the next tab. 
    This is being done first within #past-quizzes when assigning a quiz. Not 
    sure if this behaviour is desired everytime and should hence be in core 
  ###
  $('#past-quizzes-list').on 'click', '.scroll-heading', (event) ->
    event.stopPropagation()

    chart = $(this).closest '.flipchart'
    tab = flipchart.containingTab $(this)

    id = $(this).attr 'marker'
    chart.tabs 'enable', 1
    tab.attr 'marker', id

    $.get "quiz/preview.json?id=#{id}"

    # Get the list of testpapers only once. Its unlikely to have changed 
    # in the lifetime of a user-session 
    content = $(this).next()
    return true if content.children().length isnt 0 # there will always be the one download button
    btn = $("<a class='btn' href=#{gutenberg.server}/atm/#{id}/answer-key/downloads/answer-key.pdf>download pdf</a>")
    btn.appendTo content
    btn.button()

    $.get "quiz/testpapers.json?id=#{id}"
    return true

  ###
    (Process all minor-links > a here)

    1. clicking the new-quiz-link should should load the list of courses 
    taught by the logged-in teacher
  ###
  $('#minor-links').on 'click', 'a', (event) ->
    link = $(this).attr 'id'
    return if not link?

    matched = true
    teacher = $('#control-panel').attr 'marker'
    switch link
      when 'new-quiz-link'
        $.get "teacher/courses.json?id=#{teacher}"
      when 'deep-dive-link'
        $.get "teacher/sektions.json?id=#{teacher}"
      when 'my-suggestions-link'
        $.get "teacher/suggested_questions?id=#{teacher}"
      else
        matched = false

    #event.stopPropagation() if matched is true
    return true

  ###
    When a radio-button within a flipchart is clicked 
  ###
  $('.flipchart').on 'click', 'input[type="radio"]', ->
    chart = $(this).closest '.ui-tabs-panel'
    marker = $(this).attr 'marker'
    id = chart.attr 'id'

    switch id
      when 'courses-taught'
        $.get "course/verticals.json?id=#{marker}"
      when 'sektion-list'
        $.get "sektion/students.json?id=#{marker}"
      when 'testpaper'
        wide = $('#wide-panel')
        first = wide.children().eq(0).attr 'id'
        wide.empty() if first isnt 'flot-chart'
        $('#flot-chart').empty().detach().appendTo wide
        $.get "testpaper/summary.json?id=#{marker}"
      when 'student'
        tab = flipchart.containingTab $(this)
        $('#flot-chart').detach().appendTo('#toolbox')
        previous = tab.prev 'li'
        testpaper = previous.attr 'marker'
        $.get "student/responses.json?id=#{marker}&testpaper=#{testpaper}"
      when 'deep-dive-section'
        tab = flipchart.containingTab $(this)
        marker = tab.attr 'marker'
        teacher = $('#control-panel').attr 'marker'
        $.get "teacher/topics_this_section.json?id=#{teacher}&section_id=#{marker}"
      when 'deep-dive-topic'
        tab = flipchart.containingTab $(this)
        marker = tab.attr 'marker'
        previous = tab.prev 'li'
        section = previous.attr 'marker'
        $.get "sektion/proficiency.json?id=#{section}&topic=#{marker}"
        

    return true

  ###
    Step 2 of the 'quiz-building' process: topic selection
  ###
  $('#topic-selection-list').on 'click', '.scroll-heading', (event) ->
    event.stopPropagation()
    content = $(this).next()
    return if content.children().length isnt 0
    # if list already populated then do *not* repopulate it. 
    # It is highly unlikely that the list of topics will change during the session

    id = $(this).attr 'marker'
    course = flipchart.containingTab($(this)).prev().attr 'marker'
    $.get "course/topics_in.json?id=#{course}&vertical=#{id}"
    return true
   

  ###
    Step 3 of the 'quiz-building' process: topic selection 
  ###
  $('#topic-selection-list').submit ->
    form = $(this).children 'form:first'
    nChecked = coreUtil.forms.numChecked form
    if nChecked is 0
      coreUtil.interface.modalMsg "Pick at least one topic",
              ["These are topics you want to cover in the quiz. Select one or more from the list below"]
      return false

    courseId = $('#build-quiz').attr 'marker'
    teacherId = $('#control-panel').attr 'marker'
    form.attr 'action', "course/questions.json?id=#{courseId}&teacher_id=#{teacherId}"
    return true

  ###
    Step 4 of the 'quiz-building' process: Submitting the question selection 
  ###
  $('#question-options').submit ->
    form = $(this).children 'form:first'
    nChecked = coreUtil.forms.numChecked form
    if nChecked is 0
      coreUtil.interface.modalMsg "Select questions for the quiz",
              ["A question is selected when the checkbox alongside it is checked. Pick one or more questions before proceeding",
               "And don't forget to give the quiz a name"]
      return false

    courseId = $('#build-quiz').attr 'marker'
    teacherId = $('#control-panel').attr 'marker'
    form.attr 'action', "teacher/build_quiz.json?course_id=#{courseId}&id=#{teacherId}"
    flipchart.next '#build-quiz'
    return true

  $('#question-options, #typeset-for-me').on 'click', '.swiss-knife', (event) ->
    event.stopPropagation()
    for m in $(this).siblings()
      $(m).removeClass 'selected'
    $(this).addClass 'selected'

    uid = $(this).children('.label').eq(0).text()
    stop = preview.isAt uid
    current = preview.currIndex()
    preview.jump current, stop

    trigger = $(event.target)

    if trigger.is 'input[type="button"]'
      id = $(this).attr 'marker'
      liked = trigger.attr('liked')
      if not liked? or liked is "false"
        $.get "teacher/like_q.json?id=#{id}"
        trigger.attr 'liked', true
        trigger.attr 'title', 'remove from favourites list'
      else
        $.get "teacher/unlike_q.json?id=#{id}"
        trigger.attr 'liked', false
        trigger.attr 'title', 'add to favourites list'
    return true

  $('#all-my-sektions').on 'click', 'input[type="radio"]', ->
    id = $(this).attr 'marker'
    $.get "sektion/students.json?id=#{id}"
    return true

  $('#update-sektion > form:first').submit ->
    sektion_id = $('#side-panel').attr 'marker'
    return false if not sektion_id?

    coreUtil.forms.modifyAction $(this), "sektion.json?id=#{sektion_id}", 'put'
    return true

  $('#calibrations-link').click ->
    id = $('#control-panel').attr 'marker'
    $.get "load/grades.json?id=#{id}"
    $('#calibrations a').eq(0).click() # click on the first calibration to get things started
    return true

  $('#calibrations').on 'click', 'li', (event) ->
    event.stopPropagation()
    a = $(this).children('a').eq(0)
    $.get "grade/details?id=#{a.attr 'marker'}"
    $(this).addClass 'selected'
    $(m).removeClass 'selected' for m in $(this).siblings('li')
    return true

  ###
    Submit <form> everytime an <input> within $('#calibrations-summary form') loses focus.
    Loss of focus => teacher done inputting her allotment for that grade
  ###

  $('#calibrations-summary form input').blur ->
    form = $(this).closest 'form'
    form.submit()
    return true
