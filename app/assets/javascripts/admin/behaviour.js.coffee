
jQuery ->
  
  ###
    Stylize the #tbd-preview-button
  ###
  $('#tbd-preview-button').button()

  ###
    Call Popeye on #document-preview. The internals will be filled in 
    later if and when the examiner clicks on #tbd-summary-link
  ###
  $('#document-preview').popeye()

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

  ###
    Over-ride action attribute for #edit-syllabi-form just before submit.
    The default value is set in core/behaviour but should be over-ridden in
    role-specific JS files in case something else is desired
  ###

  $('#right-panel').on 'submit', 'form', ->
    ### 
      URL = /syllabus?id=<course_id>. <course_id> in turn is available 
      *not* in the parent panel - as core/behaviour assumes - but on the 
      side-panel where the courses are listed
    ###
    if $(this).closest('div').attr('id') is 'edit-syllabi-form'
      course_id = $('#side-panel').attr 'marker'
      $(this).attr 'action', "syllabus.json?id=#{course_id}"

  ###
    Connect sortable lists for Admin
  ###
  $('#macro-topic-list > #in-macros').sortable 'option', 'connectWith', '#macro-topic-list > #out-macros'
  $('#macro-topic-list > #out-macros').sortable 'option', 'connectWith', '#macro-topic-list > #in-macros'

  ###
    #macro-topic-list :  When an item is moved from out-tray to in-tray, 
    make list of micro-topics part of #edit-syllabi-form's <form> element
  ###

  $('#macro-topic-list div.in-tray:first').on 'sortreceive', (event, ui) ->
    parent = ui.item.closest '.sortable'
    return if parent.get(0) isnt $(this).get(0)

    marker = ui.item.attr 'marker'
    micros = $('#micro-topic-list').find "div[marker=#{marker}]:first"
    return if micros.length is 0

    micros = micros.detach()
    micros.appendTo '#edit-syllabi-form .peek-a-boo:first'

    ###
      macro-topic-list is used on 2 occassions : 
        1. when editing the syllabus of a course
        2. when tagging questions
      The code below is appropriate for (1) and irrelevant for (2). Irrelevant 
      because for (2), the out-tray is empty. So, there is nothing to drag
      into the in-tray and therefore no event to trigger this whole function
    ###
    for knife in micros.children()
      swissKnifeCustomize $(knife), {select:true}, true


  ###
    #macro-topic-list :  when an item is moved from in-tray to out-tray, 
    remove list of micro-topics within #edit-syllabi-form's <form> element
    and move it back to the .dump. remember to un-check all checkboxes 
    before making the move
  ###

  $('#macro-topic-list div.out-tray:first').on 'sortreceive', (event, ui) ->
    parent = ui.item.closest '.sortable'
    return if parent.get(0) isnt $(this).get(0)

    marker = ui.item.attr 'marker'
    micros = $('#edit-syllabi-form .peek-a-boo:first').find "div[marker=#{marker}]:first"
    return if micros.length is 0

    micros = micros.detach()
    swissKnifeReset micros
    micros.appendTo '#micro-topic-list'
    micros.addClass 'hidden'

  ###
    #macro-topic-list : Make the micro-topics in #edit-syllabi-form for a macro 
    in the div.in-tray visible when the corresponding radio button is clicked
  ###

  $('#macro-topic-list').on 'click', 'div.in-tray input[type="radio"]', ->
    marker = $(this).attr 'marker'
    return if not marker?

    right = $('#right-panel').children('div').first()
    switch $(right).attr 'id'
      when 'edit-syllabi-form'
        target = right.find('.peek-a-boo:first')
      when 'micro-topics-for-tagging'
        target = right.find '#micro-topic-list:first'
      else
        target = null
        alert 'something is amiss'

    return if target is null

    for micro in target.children('div[marker]')
      if $(micro).attr('marker') is marker
        $(micro).removeClass 'hidden'
      else
        $(micro).addClass 'hidden'

  ###
    When tagging questions, update the accordion-heading and fill in the 
    trojan,nay, ninja field when a micro-topic - in #micro-topics-for-tagging - 
    is selected. Needless to say, you do this for the accordion that 
    is 'active'/'open'
  ###

  $('#micro-topics-for-tagging').on 'click', 'input[type="radio"]', ->
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
    lastMinor = findLastClickedLink 'minor'
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
    

