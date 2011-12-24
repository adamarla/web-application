
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

