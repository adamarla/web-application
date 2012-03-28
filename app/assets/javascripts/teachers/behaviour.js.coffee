
jQuery ->

  $('#main-links a').click ->
    teacher = $('#control-panel').attr 'marker'
    id = $(this).attr 'id'
    switch id
      when 'quizzes-link'
        $.get 'quizzes/list.json'
        $.get "teachers/roster.json?id=#{teacher}"
      when 'report-cards-link'
        $.get "teacher/testpapers.json?id=#{teacher}"
    return true

  # Assigning a Quiz to students selected in #student-list
  $('#student-list > form:first').submit ->
    ###
      This thing will need the quiz's ID. And that is available 
      as 'marker' on the 'side' panel
    ###
    chart = $(this).closest '.flipchart'
    return false if chart.length is 0
    quiz = chart.attr 'marker'
    return if not quiz?

    coreUtil.forms.modifyAction $(this), "quiz/assign.json?id=#{quiz}", 'put'
    return true

  ########################################################
  #  Key-press event processing. Best to attach to $(document)
  # so that event is always caught, even when focus in NOT 
  # on #document-preview
  ########################################################

  $(document).keypress (event) ->
    # No point in processing key-events if #document-preview is not being seen
    return if $('#document-preview').hasClass 'hidden'

    dbId = preview.currDBId()
    imgId = preview.currIndex()

    switch event.which
      when 115 # 'S' pressed => select
        selection.add preview.currDBId()
        preview.softSetImgCaption 'selected'
        preview.hardSetImgCaption imgId, 'selected'
      when 100 # 'D' pressed => deselect 
        selection.remove preview.currDBId()
        preview.softSetImgCaption 'dropped'
        preview.hardSetImgCaption imgId, 'dropped'
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
  $('#past-quizzes').on 'click', '.accordion-heading', ->
    chart = $(this).closest '.flipchart'
    chart.tabs 'enable', 1
    $.get "quiz/preview.json?id=#{$(this).attr 'marker'}"
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
    switch link
      when 'new-quiz-link'
        teacher = $('#control-panel').attr 'marker'
        $.get "teacher/courses.json?id=#{teacher}"
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
        $.get "sektions/students.json?id=#{marker}"
      when 'testpaper'
        $.get "testpaper/students.json?id=#{marker}"
      when 'student'
        tab = flipchart.containingTab $(this)
        previous = tab.prev 'li'
        testpaper = previous.attr 'marker'
        $.get "student/responses.json?id=#{marker}&testpaper=#{testpaper}"

    return true


  ###
    Step 3 of the 'quiz-building' process: topic selection 
  ###
  $('#topic-selection-list').submit ->
    courseId = $('#build-quiz').attr 'marker'
    form = $(this).children 'form:first'
    form.attr 'action', "course/questions.json?id=#{courseId}"
    return true

  ###
    Step 4 of the 'quiz-building' process: Submitting the question selection 
  ###
  $('#question-options').submit ->
    courseId = $('#build-quiz').attr 'marker'
    teacherId = $('#control-panel').attr 'marker'

    form = $(this).children 'form:first'
    form.attr 'action', "teacher/build_quiz.json?course_id=#{courseId}&id=#{teacherId}"
    return true

  ###
    When reviewing choices of questions, synchronize scrolling in the document preview 
    with choices shown in the side-panel. In particular, enable only the choice for
    which the preview is being shown
  ###
  $(document).keydown (event) ->
    return if $('#wide-panel').hasClass 'hidden'

    images = $('#wide-panel').children().first()
    return if images.length is 0
    
    if images.hasClass 'ppy-placeholder'
      preview.scrollSidePnlList event

    return true

