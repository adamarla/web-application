
jQuery ->
  
  ###
    #new-examiner-link
  ###

  $('#add-examiner-link').click ->
    $('#new-examiner').dialog('option', 'title', 'New Examiner').dialog('open')

  ###
    #courses-link on click (dummy)
  ###

  $('#courses-link').click ->
    $.get 'topics/list'
