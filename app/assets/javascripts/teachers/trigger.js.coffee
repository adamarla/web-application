
############################################################################
## Bootstrap 
############################################################################

jQuery ->
  # Auto-click on the 'quizzes' tab. This will initiate the $.get request to get things started
  # $('#left-1 > ul:first a:first').tab 'show'

  $('#left-quizzes').on 'click', '.single-line', (event) ->
    event.stopPropagation()
    marker = $(this).attr 'marker'
    $.get "quiz/preview.json?id=#{marker}"

    return true

  $('#select-all-for-quiz').click (event) ->
    event.stopPropagation()
    target = $('#sektions-tab').children('.tab-content').eq(0).children('form.active').eq(0)
    for m in target.children('.single-line')
      $(m).click()
    return true

  $('#build-worksheet').click (event) ->
    event.stopPropagation()
    form = $(this).parent().siblings('form.active').eq(0)
    id = $('#tab-wsb-quizzes').parent().attr 'marker'
    action = "quiz/assign?id=#{id}"
    form.attr 'action', action
    form.submit()
    return true
