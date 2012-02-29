
jQuery ->
  
  ###
    In order to know what server this JS code is running on, one of the
    first things we do while loading core JS files is issue an AJAX ping request

    However, the results of the ping will take time to come back and if the 
    client computer continues with JS loading, then we would never be able 
    to set the deployment-specific JS variables that we need to

    So, we halt loading for a reasonable time and wait for the response 
    to come back and be processed before proceeding 
  ###
  window.setTimeout () ->
    $('#scan-loader-link').attr 'href', "#{gutenberg.server}/scanbot/dist/launch.jnlp"
  , 1000

  ###
    #new-examiner-link
  ###

  $('#add-examiner-link').click ->
    $('#new-examiner').dialog('option', 'title', 'New Examiner').dialog('open')

  $('#main-links a').click ->
    id = $(this).attr 'id'
    switch id
      when 'schools-link' then $.get 'schools/list'
      when 'boards-link' then $.get 'boards/summary'
      when 'courses-link' then $.get 'courses/list'
      when 'workbench-link'
        $.get 'questions/list.json'
        $.get 'verticals/list.json'
    return true

  ###
    On minor-links click
  ###
  $('#control-panel').on 'click', '#minor-links a', ->
    id = $(this).attr 'id'
    switch id
      when 'grading-link' then $.get 'examiner/pending_quizzes'
    return true

  ###
    When a radio-button within a flipchart is clicked 
  ###
  $('.flipchart').on 'click', 'input[type="radio"]', ->
    chart = $(this).closest '.ui-tabs-panel'
    id = $(this).attr 'marker'
    switch chart.attr 'id'
      when 'pending-quizzes' then $.get "examiner/pending_pages.json?id=#{id}"

  ###
    Edit <form> actions
  ###
  adminForms = '#edit-school, #new-school, #new-teacher, #new-student, #student-list, 
                #edit-syllabi-form, #new-studygroups, #edit-student-klass-mapping'

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
        action = "school/students/add.json?id=#{school}"
      when 'new-teacher'
        return false if not school?
        action = "teacher.json?id=#{school}"
      when 'student-list'
        sektion = $('#middle-panel').attr 'marker'
        return false if not sektion?
        action = "sektions/update_student_list.json?id=#{sektion}"
        method = 'put'
      when 'edit-syllabi-form'
        course = $('#side-panel').attr 'marker'
        return false if not course?
        action = "syllabus.json?id=#{course}"
        method = 'put'
      when 'new-studygroups'
        return false if not school?
        action = "sektion.json?id=#{school}"
      when 'edit-student-klass-mapping'
        teacher = $('#middle-panel').attr 'marker'
        return false if not teacher?
        action = "teacher/update_roster.json?id=#{teacher}"
        method = 'put'

    coreUtil.forms.modifyAction $(this), action, method
    return true

  ###
    Connect sortable lists for Admin
  ###
  $('#vertical-selected-list').sortable 'option', 'connectWith', '#vertical-deselected-list'
  $('#vertical-deselected-list').sortable 'option', 'connectWith', '#vertical-selected-list'

  ###
    edit-syllabi form should acquire or lose elements depending on whether a 
    vertical has been moved from selected -> deselected or the other way round
  ###
  $('.sortable').on 'sortreceive', (event, ui) ->
    parent = ui.item.closest '.sortable'
    return if parent.get(0) isnt $(this).get(0)

    id = ui.item.attr 'marker'
    type = if parent.hasClass 'selected' then 'deselected' else 'selected'
    adminUtil.mnmToggle type, id, {select:true}

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
  # AJAX requests to issue when radio-buttons in various panels are clicked
  ###########################################################################

  $('#courses-summary').on 'click', 'input[type="radio"]', ->
    marker = $(this).attr 'marker'
    $.get "course/coverage.json?id=#{marker}"

  $('#schools-summary').on 'click', 'input[type="radio"]', ->
    # What AJAX to issue depends on which minor-link has been selected
    lastMinor = coreUtil.interface.lastClicked 'minor'
    marker = $(this).attr 'marker'

    if lastMinor.length is 0
      $.get "school/sektions.json?id=#{marker}"
      return

    switch lastMinor.attr 'id'
      when 'edit-roster-link'
        # Clear out the #right-panel which has sektion-information
        for e in $('#right-panel').find '.purgeable'
          $(e).empty()
        # Then issue the AJAX request
        $.get "teachers/list.json?id=#{marker}"
      when 'edit-studygroups-link'
        $.get "school/sektions.json?id=#{marker}"
        $.get "school/unassigned-students.json?id=#{marker}"
      when 'add-n-edit-school-link'
        $.get "school.json?id=#{marker}"
    return true

  $('#teachers-list').on 'click', 'input[type="radio"]', ->
    marker = $(this).attr 'marker'
    $.get "teachers/roster.json?id=#{marker}"

  ###
    On load, auto-click the first main-link > a that has attribute default='true'
  ###
  $('#main-links a[default="true"]:first').click()

  ###
    When an untagged question in #examiner-untagged is selected, then set the 
    hidden <input> field in #misc-traits > form with the selected question's id.
    Also, load the preview
  ###
  $('#examiner-untagged').on 'click', 'input[type="radio"]', ->
    id = $(this).attr 'marker'
    target = $('#misc-traits input#misc_id').first() # formtastic generated id
    target.val id
    $.get "question/preview.json?id=#{id}"
    return true

  ###
    When a micro-topic in #micro-selection is selected, then set the 
    hidden <input> field in #misc-traits > form with the selected topic's id
  ###
  $('#micro-selection').on 'click', 'input[type="radio"]', ->
    id = $(this).attr 'marker'
    target = $('#misc-traits input#misc_micro_topic_id').first() # formtastic generated id
    target.val id
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
    $('#block-db-slots').dialog 'close'
    return true

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


