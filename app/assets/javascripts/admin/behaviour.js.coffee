
jQuery ->
  
  ###
    #new-examiner-link
  ###

  $('#grading-canvas').on 'click', (event) ->
    canvas.record event

  $('#add-examiner-link').click ->
    $('#new-examiner').dialog('option', 'title', 'New Examiner').dialog('open')

  $('#videos-link').click ->
    $('#new-video').dialog('option', 'title', 'New Video').dialog('open')

  $('#add-boards-link').click ->
    $('#new-board-form').dialog('option', 'title', 'school boards').dialog('open')

  $('#main-links a').click ->
    return if $(this).attr('block_ajax') is "true"
    id = $(this).attr 'id'
    switch id
      when 'account-link' then $.get 'examiners/list'
      when 'boards-link' then $.get 'boards/summary'
      when 'courses-link'
        $.get 'courses/list'
      when 'schools-link' then $.get 'schools/list'
      when 'workbench-link'
        $.get 'questions/list.json'
        $.get 'verticals/list'
    return true

  ###
    On minor-links click
  ###
  $('#control-panel').on 'click', '#minor-links a', ->
    id = $(this).attr 'id'
    switch id
      when 'grading-link'
        $.get 'examiner/pending_quizzes'
        canvas.initialize '#grading-canvas'
      when 'suggestions-link'
        flipchart.enableAll $('#pending-suggestions')
        id = $('#control-panel').attr 'marker'
        $.get "examiner/suggestions/#{id}"
    return true

  ###
    Edit <form> actions
  ###
  adminForms = '#edit-school, #new-school, #new-teacher, #new-student,
                #edit-syllabi-form, #teacher-specialization'

  $(adminForms).on 'submit', 'form', ->
    parent = $(this).parent().attr 'id'
    school = $('#side-panel').attr 'marker'
    method = null

    switch parent
      when 'edit-school'
        return false if not school?
        action = "school.json?id=#{school}"
        method = 'put'
      when 'new-school'
        action = "school.json"
      when 'new-student'
        return false if not school?
        action = "add_students.json?id=#{school}"
      when 'new-teacher'
        return false if not school?
        action = "teacher.json?id=#{school}"
      when 'edit-syllabi-form'
        course = $('#side-panel').attr 'marker'
        return false if not course?
        action = "syllabus.json?id=#{course}"
        method = 'put'
      when 'teacher-specialization'
        teacher = $('#middle-panel').attr 'marker'
        return false if not teacher?
        action = "update_specialization.json?id=#{teacher}"

    coreUtil.forms.modifyAction $(this), action, method
    return true

  ###########################################################################
  # AJAX requests triggered by other actions 
  ###########################################################################
  $('#teachers-list').on 'click', 'input[type="button"]', ->
    # if the clicked button is within teachers-list, then it must be 
    # the 'edit' button for the selected teacher 
    marker = $(this).closest('.swiss-knife').attr('marker')
    $.get "teacher/load.json?id=#{marker}"
    return true

  $('#courses-summary').on 'click', 'input[type="button"]', ->
    # The 'edit' button within #courses-summary. Clicked when editing course information
    marker = $(this).closest('.swiss-knife').attr('marker')
    return if not marker?
    $.get "course/profile.json?id=#{marker}"
    return true
    

  ###########################################################################
  # If sth. is selected in the side-panel and then a minor link is clicked, 
  # then load the applicable information for that selection. 
  ###########################################################################

  $('#courses-summary').on 'click', 'input[type="radio"]', ->
    marker = $(this).attr 'marker'
    $.get "course/coverage.json?id=#{marker}"

  $('#schools-summary').on 'click', 'input[type="radio"]', ->
    # What AJAX to issue depends on which minor-link has been selected
    lastMinor = coreUtil.interface.lastClicked 'minor'
    marker = $(this).attr 'marker'

    if lastMinor.length isnt 0
      switch lastMinor.attr 'id'
        when 'edit-roster-link'
          $.get "teachers/list.json?id=#{marker}"
        when 'add-n-edit-school-link'
          $.get "school.json?id=#{marker}"
    return true

  ###########################################################################
  # Handle all minor-link > a clicks here 
  ###########################################################################

  $('#minor-links').on 'click', 'a', (event) ->
    id = $(this).attr 'id'
    switch id
      when 'edit-roster-link'
        $('#specialization-chart').accordion scroll.options
    return true

  $('#teachers-list').on 'click', 'input[type="radio"]', ->
    marker = $(this).attr 'marker'
    $.get "teacher/specializations.json?id=#{marker}"

  ###
    On load, auto-click the first main-link > a that has attribute default='true'
  ###
  $('#main-links a[default="true"]:first').click()

  ###
    When a question - tagged or untagged - in #examiner-untagged is selected
  ###
  $('#examiner-untagged').on 'click', 'input[type="radio"]', ->
    id = $(this).attr 'marker'
    $.get "question/preview.json?id=#{id}"
    return true

  $('#misc-traits > form').submit ->
    tab = flipchart.containingTab $(this)
    return false if tab.length is 0 # block submission
    topic = tab.prev('li').attr 'marker'
    question = tab.prev('li').prev('li').attr 'marker'
    $(this).attr 'action', "/question?id=#{question}&topic=#{topic}"
    return true

  ###
    Pop up a modal dialog on #db-slots-link click
  ###
  $('#control-panel').on 'click', '#db-slots-link', ->
    $('#block-db-slots').dialog 'open'

  ###
    Close the #block-db-slots dialog if the 'cancel' button is clicked
  ###
  $('#block-db-slots').on 'click', '#btn-cancel', (event) ->
    event.stopPropagation()
    $('#created-slots').empty() # purge any old summary from previous call
    $('#block-db-slots').dialog 'close'
    return false

  ###
    Issue request for new slots if #btn-submit in #block-db-slots is clicked 
  ###
  $('#block-db-slots').on 'click', '#btn-submit', (event) ->
    event.stopPropagation()
    examiner_id = $('#control-panel').attr 'marker'
    $('#block-db-slots').dialog 'close'
    $('#block-db-operation-summary').dialog 'open'
    $.get "examiner/block_db_slots.json?id=#{examiner_id}"
    return true
 
  ###
    When the 'edit' link for a yardstick is clicked
  ###
  $('#yardsticks-summary a.edit').click (event) ->
    id = $(this).attr 'marker'
    coreUtil.forms.modifyAction '#edit-yardstick', "yardstick.json?id=#{id}", 'put'
    $.get "yardstick.json?id=#{id}"
    event.stopPropagation()
    return true

  ###
    Send request to web-service to shift any new scans from staging -> locker
    and then assign these scans to examiners. Any examiner can inititate this
    action for everyone else
  ###
  $('#new-scans-link').click (event) ->
    event.stopPropagation()
    $.get 'examiner/update_workset'
    return true

  ###
    Clicking the undo button when grading
  ###
  $('#undo-btn').click ->
    canvas.undo()

  ###
    Selecting a pending quiz in #pending-quizzes
  ###
  $('#pending-quizzes').on 'click', 'input[type="radio"]', ->
    examiner = $('#control-panel').attr 'marker'
    quiz = $(this).attr 'marker'
    $.get "quiz/pending_pages.json?id=#{quiz}&examiner_id=#{examiner}"
    return true

  ###
    Selecting a pending page in #pending-pages should load all the scans
    assigned to the logged-in examiner
  ###
  $('#pending-pages').on 'click', 'input[type="radio"]', ->
    examiner = $('#control-panel').attr 'marker'
    page = $(this).attr 'marker'
    tab = flipchart.containingTab $(this)
    quiz = tab.prev('li').attr 'marker'
    $.get "quiz/pending_scans.json?id=#{quiz}&examiner_id=#{examiner}&page=#{page}"
    return true

  $('#grading-panel > form').submit ->
    ret = canvas.decompile()
    clicks = $(this).find 'input[name="clicks"]:first'
    clicks.val ret
    return true

  ###
    During question-tagging, show selects for only as many sub-parts as have 
    been picked by the examiner. For stand-alone questions, select '0' as
    number of subparts. Saying that a question has one sub-part makes no sense. 
    Either it has none or has a minimum of two
  ###
  $('#misc_num_parts').change ->
    val = parseInt($(this).val())
    val = val - 1 if val > 0

    subpartTags = $(this).parent().siblings('.subpart-tags')
    for j in [0...10]
      tag = subpartTags.eq(j)

      # pick the 2nd value in both the marks & length select. This means 
      # marks = 2 and length = half-page, by default 
      tag.find('select').val 2
      if (j <= val) then tag.removeClass('hidden') else tag.addClass('hidden')
    return true


  ###
    (New Course): Clicking on a scroll-heading that represents a vertical should
    load the list of available topics within that vertical
  ###
  $('#tag-question-topics, #define-course-topics').on 'click', '.scroll-heading', (event) ->
    event.stopPropagation()
    content = $(this).next()

    if content.children().length is 0 # empty thus far
      id = $(this).attr 'marker'
      $.get "vertical/topics.json?id=#{id}"
    return true

  ###
    When editing a course, one must not only load all the topics but also 
    the difficulty level of each covered topic in the course. A course
    must therefore be selected first
  ###

  $('#edit-course-topics').on 'click', '.scroll-heading', (event) ->
    event.stopPropagation()
    course = $('#side-panel').attr 'marker'
    if not course?
      alert 'select a course first'
      return false

    #$.get "course/coverage.json?id=#{course}"
    return true

  ###
  ###

  $('#days-since-receipt, #typeset-wip, #typeset-completed').on 'click', '.swiss-knife', (event) ->
    event.stopPropagation()
    uid = $(this).children('.label').eq(0).text()
    stop = preview.isAt uid
    current = preview.currIndex()
    preview.jump current, stop
    return true
