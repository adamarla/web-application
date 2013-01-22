
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
    form = $(this).closest('.tab-content').children('form.active').eq(0)
    id = $('#tab-wsb-quizzes').parent().attr 'marker'

    # See teachers/_wsb-sektions
    publishBtn = $(this).parent().prev().children('#btn-publish-ws').eq(0)
    publish = publishBtn.hasClass 'active'

    action = if publish then "quiz/assign?id=#{id}&publish=yes" else "quiz/assign?id=#{id}"
    form.attr 'action', action
    form.submit()
    return true

  $('#tab-qzb-topics').on 'shown', (event) ->
    pane = $(this).closest('.nav-tabs').eq(0).next().children('.tab-pane.active').eq(0)
    btnGroup = pane.find('.btn-group').eq(0)
    buttonGroup.initialize btnGroup unless btnGroup.length is 0
    return true

