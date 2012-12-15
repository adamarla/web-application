
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

  $('#select-all-for-quiz').click (event) ->
    event.stopPropagation()
    target = $('#sektions-tab').children('.tab-content').eq(0).children('form.active').eq(0)
    for m in target.children('.single-line')
      $(m).click()
    return true

  $('#build-worksheet').click (event) ->
    event.stopPropagation()
    activeTab = $('#lp-worksheet-builder').children('ul').eq(0).children('li').eq(0)
    quiz = activeTab.attr 'marker'
    form = $('#sektions-tab').children('.tab-content').eq(0).children('form.active').eq(0)
    form.attr 'action', "quiz/assign.json?id=#{quiz}"
    form.trigger 'submit'
    return true
  
