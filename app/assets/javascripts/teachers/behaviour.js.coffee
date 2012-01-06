
jQuery ->
  ###
    Change the default styling of labels in #macro-search-form
  ###

  for label in $('#macro-search-form').find 'label'
    $(label).addClass 'inline-label'

  ###
    Clicking new-quiz-link
  ###
  $('#new-quiz-link').click ->
