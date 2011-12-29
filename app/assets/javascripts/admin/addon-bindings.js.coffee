
jQuery ->
  
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

  $('#macro-topic-list .in-tray:first').on 'sortreceive', (event, ui) ->
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

  $('#macro-topic-list .out-tray:first').on 'sortreceive', (event, ui) ->
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
    in the .in-tray visible when the corresponding radio button is clicked
  ###

  $('#macro-topic-list').on 'click', '.in-tray input[type="radio"]', ->
    marker = $(this).attr 'marker'
    return if not marker?

    for micro in $('#edit-syllabi-form .peek-a-boo').children('div[marker]')
      if $(micro).attr('marker') is marker
        $(micro).removeClass 'hidden'
      else
        $(micro).addClass 'hidden'


