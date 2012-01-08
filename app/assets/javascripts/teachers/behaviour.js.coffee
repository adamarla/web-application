
jQuery ->
  ###
    Treatment of <label>s in #macro-search-form. The <label>s have been 
    generated by formtastic. So, one way or the other, we have to handle them
  ###

  for label in $('#macro-search-form').find 'label'
    #$(label).addClass 'inline-label'
    $(label).addClass 'hidden'

  $('#macro-search-form form:first').submit ->
    ### 
      This form has > 1 submit buttons. So, to know what needs to be done
      on submission, one first needs to know which of the submit buttons 
      was clicked
    ###
    for button in $(this).find 'input[type="submit"]'
      clicked = $(button).attr 'clicked'
      break if clicked is 'true' # yes, its a string - not boolean - comparison

    teacherId = $(this).attr 'marker'
    boardId = $(this).attr 'board_id'

    switch $(button).attr 'id'
      when 'btn-teacher-coverage'
        $(this).attr 'action', "/teacher/coverage.json?id=#{teacherId}"
      when 'btn-candidate-questions'
        $(this).attr 'action', "/quiz/candidate_questions.json?id=#{teacherId}&board_id=#{boardId}"
      else return false
    return true

