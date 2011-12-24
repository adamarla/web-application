
jQuery ->
  
  ###
    #new-examiner-link
  ###

  $('#add-examiner-link').click ->
    $('#new-examiner').dialog('option', 'title', 'New Examiner').dialog('open')

  ###
    Connect sortable lists for Admin
  ###
  $('#macro-topic-list > #in-macros').sortable 'option', 'connectWith', '#macro-topic-list > #out-macros'
  $('#macro-topic-list > #out-macros').sortable 'option', 'connectWith', '#macro-topic-list > #in-macros'

  ###
    #macro-topic-list :  When an item is moved from out-tray to in-tray, 
    make list of micro-topics part of #edit-syllabi-form's <form> element
  ###

  $('#macro-topic-list').on 'sortreceive', '.in-tray:first', (event, ui) ->
    parent = ui.item.closest '.sortable'
    return if parent.get(0) isnt $(this).get(0)

    marker = ui.item.children('.radio:first').attr 'marker'
    micros = $('#edit-syllabi-form .dump:first').find "div[marker=#{marker}]:first"
    return if micros.length is 0

    micros = micros.detach()
    micros.appendTo '#edit-syllabi-form .peek-a-boo:first'


  ###
    #macro-topic-list :  When an item is moved from in-tray to out-tray, 
    remove list of micro-topics within #edit-syllabi-form's <form> element
    and move it back to the .dump. Remember to un-check all checkboxes 
    before making the move
  ###

  $('#macro-topic-list').on 'sortreceive', '.out-tray:first', (event, ui) ->
    parent = ui.item.closest '.sortable'
    return if parent.get(0) isnt $(this).get(0)

    marker = ui.item.children('.radio:first').attr 'marker'
    micros = $('#edit-syllabi-form .peek-a-boo:first').find "div[marker=#{marker}]:first"
    return if micros.length is 0

    micros = micros.detach()
    micros.appendTo '#edit-syllabi-form .dump:first'
    micros.addClass 'hidden'

