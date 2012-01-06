
jQuery ->
  ###
    Hide the labels in #macro-search-form. The labels will be there
    because the form has been generated using formtastic. But we don't 
    have to see them, do we ? 
  ###

  for label in $('#macro-search-form').find 'label'
    alert '1'
    $(label).addClass 'hidden'

  ###
    Clicking new-quiz-link
  ###
  $('#new-quiz-link').click ->
