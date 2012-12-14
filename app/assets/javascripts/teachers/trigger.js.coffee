
############################################################################
## Bootstrap 
############################################################################

jQuery ->
  # Auto-click on the 'quizzes' tab. This will initiate the $.get request to get things started
  $('#lp-worksheet-builder > ul:first a:first').tab 'show'

  $('#lp-quizzes').on 'click', '.single-line', (event) ->
    event.stopPropagation()
    marker = $(this).attr 'marker'
    $.get "quiz/preview.json?id=#{marker}"

    return true
  
