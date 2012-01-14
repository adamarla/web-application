
jQuery ->
  ###
    Treatment of <label>s in #quiz-builder-form. The <label>s have been 
    generated by formtastic. So, one way or the other, we have to handle them
  ###

  for label in $('#quiz-builder-form').find 'label'
    #$(label).addClass 'inline-label'
    $(label).addClass 'hidden'

  $('#quiz-builder-form form:first').submit ->
    ### 
      This form has > 1 submit buttons. So, to know what needs to be done
      on submission, one first needs to know which of the submit buttons 
      was clicked
    ###
    for button in $(this).find 'input[type="submit"]'
      clicked = $(button).attr 'clicked'
      break if clicked is 'true' # yes, its a string - not boolean - comparison

    teacherId = $(this).attr 'marker'
    boardId = $(this).attr 'board_id'

    switch $(button).attr 'id'
      when 'btn-teacher-coverage'
        $(this).attr 'action', "/teacher/coverage.json?id=#{teacherId}"
      when 'btn-candidate-questions'
        $(this).attr 'action', "/quiz/candidate_questions.json?id=#{teacherId}&board_id=#{boardId}"
      else return false
    return true

  $('#btn-build-quiz').click ->
    # 1. Collect information about the teacher, subject and klass from
    #    the <form> within which this button is
    form = $('#quiz-builder-form form:first')
    teacher = form.attr 'marker'
    subject = form.find('#subject-dropdown option:selected:first').text()
    klass = form.find('#klass-dropdown option:selected:first').text()

    # 2. Then, POST the above collected data with the question selection
    $.post '/quiz.json', {'selected' : selection.list, 'id' : teacher, 'klass' : klass, 'subject' : subject}

  $('#quizzes-link').click ->
    teacher = $('#control-panel').attr 'marker'
    $.get 'quizzes/list.json'
    $.get "teachers/roster.json?id=#{teacher}"
    return true

  # Clicking of preview button
  $('#quizzes-summary').on 'click', 'input[type="button"]', ->
    
    if $(this).attr('in-preview') is 'yes'
      $(this).val 'preview'
      show = ['middle', 'right']
      hide = ['wide']
      $(this).attr 'in-preview', 'no'
    else
      $(this).val 'back'
      show = ['wide']
      hide = ['middle', 'right']
      id = $(this).closest('.swiss-knife').attr('marker')
      $.get "quiz/preview.json?id=#{id}"
      $(this).attr 'in-preview', 'yes'

    for type in show
      panel = $("##{type}-panel")
      panel.removeClass 'hidden'
    for type in hide
      panel = $("##{type}-panel")
      panel.addClass 'hidden'
    return true

  # Assigning a Quiz to students selected in #enrolled-student-list 
  $('#enrolled-student-list > form:first').submit ->
    ###
      This thing will need the quiz's ID. And that is available 
      as 'marker' on the 'side' panel
    ###
    quiz = $('#side-panel').attr 'marker'
    return if not quiz?

    coreUtil.forms.modifyAction $(this), "quiz/assign.json?id=#{quiz}", 'put'
    return true


  # Load the student list into #enrolled-student-list on section selection 
  $('#teacher-roster').on 'click', 'input[type="radio"]', ->
    section = $(this).attr 'marker'
    return if not section?
    $.get "study_groups/students.json?id=#{section}"
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
        preview.changeImgCaption imgId, 'selected'
      when 100 # 'D' pressed => deselect 
        selection.remove preview.currDBId()
        preview.changeImgCaption imgId, ''
    return true

