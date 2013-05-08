
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
    $(m).click() for m in $('#wsb-sektions').children('.single-line')
    return false

  $('#build-worksheet').click (event) ->
    someChecked = false
    for m in $('#wsb-sektions').find("input[type='checkbox']")
      someChecked |= $(m).prop('checked')
      break if someChecked
    
    event.stopPropagation()
    return someChecked

    ###
    form = $(this).closest('.tab-content').children('form').eq(0)
    id = $('#tab-wsb-quizzes').parent().attr 'marker'

    # See teachers/_wsb-sektions
    publishBtn = $(this).parent().prev().children('#btn-publish-ws').eq(0)
    publish = publishBtn.hasClass 'active'

    action = if publish then "quiz/assign?id=#{id}&publish=yes" else "quiz/assign?id=#{id}"
    form.attr 'action', action
    form.submit()
    alert '1'
    return true
    ###

  $('#tab-qzb-topics').on 'shown', (event) ->
    pane = $(this).closest('.nav-tabs').eq(0).next().children('.tab-pane.active').eq(0)
    btnGroup = pane.find('.btn-group').eq(0)
    buttonGroup.initialize btnGroup unless btnGroup.length is 0
    return true

  ###
  $('#btn-editqz-nodrop').click (event) ->
    target = $('#editqz-1')
    for m in target.children('.single-line')
      $(m).removeClass 'selected'
      $(j).prop('checked', false) for j in $(m).find("input[type='checkbox']")
      $(k).removeClass 'badge-warning' for k in $(m).children('.badge')
    return true
  ###

  $('#form-qzb').submit (event) ->
    root = $(this).find('#qzb-questions').eq(0)
    sthSelected = false

    alert "root not found!" if root.length is 0
    entries = root.find ('.single-line')
    alert "no lines" if entries.length is 0

    for m in entries
      checkbox = $(m).find "input"
      alert "no checkbox" if checkbox.length is 0
    return false
    ###

    checkBoxes = root.find ".single-line > button > input"
    alert checkBoxes.length

    for m in checkBoxes
      s = $(m).prop('checked')
      alert "#{s} --> #{typeof s}"
      sthSelected = sthSelected || s
      break if sthSelected

    return true if sthSelected
    notifier.show 'n-qzb-no-selection'
    return false


