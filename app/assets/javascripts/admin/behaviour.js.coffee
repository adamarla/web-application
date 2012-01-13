
jQuery ->
  
  ###
    Stylize the #tbd-preview-button
  ###
  $('#tbd-preview-button').button()

  ###
    #new-examiner-link
  ###

  $('#add-examiner-link').click ->
    $('#new-examiner').dialog('option', 'title', 'New Examiner').dialog('open')

  ###
    (control-panel) : #tbd-link click
  ###
  $('#tbd-link').click ->
    $.get 'questions/list.json'
    $.get 'macros/list.json'
    $('#tbd-preview-button').val 'preview'
    return true

  ###
    Edit <form> actions
  ###
  $('#edit-school, #new-school, #new-teacher, #new-student, #student-list, #edit-syllabi-form').on 'submit', 'form', ->
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
        action = "student.json?id=#{school}"
      when 'new-teacher'
        return false if not school?
        action = "teacher.json?id=#{school}"
      when 'student-list'
        section = $('#middle-panel').attr 'marker'
        return false if not section?
        action = "study_groups/update_student_list.json?id=#{section}"
        method = 'put'
      when 'edit-syllabi-form'
        course = $('#side-panel').attr 'marker'
        return false if not course?
        action = "syllabus.json?id=#{course}"
        method = 'put'

    coreUtil.forms.modifyAction $(this), action, method
    return true

  ###
    Connect sortable lists for Admin
  ###
  $('#macro-selected-list').sortable 'option', 'connectWith', '#macro-deselected-list'
  $('#macro-deselected-list').sortable 'option', 'connectWith', '#macro-selected-list'

  ###
    edit-syllabi form should acquire or lose elements depending on whether a 
    macro-topic has been moved from selected -> deselected or the other way round
  ###
  $('.sortable').on 'sortreceive', (event, ui) ->
    parent = ui.item.closest '.sortable'
    return if parent.get(0) isnt $(this).get(0)

    id = ui.item.attr 'marker'
    type = if parent.hasClass 'selected' then 'deselected' else 'selected'
    adminUtil.mnmToggle type, id, {select:true}
    
  ###
    When tagging questions, update the accordion-heading and fill in the 
    trojan,nay, ninja field when a micro-topic - in #micro-topics-for-tagging - 
    is selected. Needless to say, you do this for the accordion that 
    is 'active'/'open'
  ###

  $('#micro-tagging-options').on 'click', 'input[type="radio"]', ->
    marker = $(this).attr 'marker'
    label = $(this).siblings('div.label').first().text()

    # Find the open tab in accordion
    
    # ok,ok .. I got chammak challo running in my head
    akon = $('#tbds-summary').find '.samurai-armory:first'
    openTab = akon.accordion('option', 'active')

    header = akon.find('.accordion-heading').eq(openTab)
    panel = akon.find('.accordion-content').eq(openTab)

    header.children().eq(2).text label # the .footnote element in header
    panel.children('input[type="hidden"]').first().val marker # the ninja field

  ###
    What to do when a 'preview' button in '#tbds-summary' is clicked
  ###

  $('#tbd-preview-button').click ->
    showWide = $('#wide-panel').hasClass 'hidden'
    for type in ['middle', 'right']
      panel = $("##{type}-panel")
      if showWide then panel.addClass('hidden') else panel.removeClass('hidden')

    if showWide is false
      preview = $('#wide-panel').children().first() # should be a .ppy-placeholder
      preview = preview.detach()
      preview.appendTo '#toolbox'
      $('#wide-panel').addClass 'hidden'
      $(this).val 'preview'
    else
      $('#wide-panel').removeClass 'hidden'
      preview = $('#toolbox').find '.ppy-placeholder:first' # pre-generated
      preview.appendTo '#wide-panel'
      $(this).val 'back'

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

  $('#yardsticks-summary').on 'click', 'input[type="radio"]', ->
    marker = $(this).attr 'marker'
    $.get "yardstick.json?id=#{marker}"

  $('#schools-summary').on 'click', 'input[type="radio"]', ->
    # What AJAX to issue depends on which minor-link has been selected
    lastMinor = coreUtil.interface.lastClicked 'minor'
    return if lastMinor.length is 0

    marker = $(this).attr 'marker'
    switch lastMinor.attr 'id'
      when 'edit-roster-link'
        # Clear out the #right-panel which has section-information
        for e in $('#right-panel').find '.purgeable'
          $(e).empty()
        # Then issue the AJAX request
        $.get "teachers/list.json?id=#{marker}"
      when 'edit-studygroups-link'
        $.get "school/sections.json?id=#{marker}"
        $.get "school/unassigned-students.json?id=#{marker}"
      when 'add-n-edit-school-link'
        $.get "school.json?id=#{marker}"
    return true

  $('#teachers-list').on 'click', 'input[type="radio"]', ->
    marker = $(this).attr 'marker'
    $.get "teachers/roster.json?id=#{marker}"
    

