
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

  $('#tab-qzb-topics').on 'shown', (event) ->
    pane = $(this).closest('.nav-tabs').eq(0).next().children('.tab-pane.active').eq(0)
    btnGroup = pane.find('.btn-group').eq(0)
    buttonGroup.initialize btnGroup unless btnGroup.length is 0
    return true

  ###
    [qzb] : Ensure that atleast one question is selected
  ###
  $('#form-qzb').submit (event) ->
    root = $(this).find('#qzb-questions').eq(0)
    isBlank = sthSelected = false
    checkBoxes = root.find ".single-line > .btn > input"

    for m in checkBoxes
      s = $(m).prop('checked')
      sthSelected = sthSelected || s
      break if sthSelected
    
    if sthSelected
      name = $(this).find("input[type='text']").eq(0).val()
      isBlank = if (not name or /^\s*$/.test(name)) then true else false
      notifier.show 'n-qzb-no-name' if isBlank
    else
      notifier.show 'n-qzb-no-selection'
    return (sthSelected and not isBlank)

  ###
    [wsb] : Ensure that atleast one student is selected (issue #70) 
  ###
  $('#form-wsb-3').submit (event) ->
    students = $(this).children("[id='wsb-sektions']").eq(0)
    sthSelected = false
    checkBoxes = students.find("input[type='checkbox']")

    for m in checkBoxes
      s = $(m).prop('checked')
      sthSelected = sthSelected || s
      break if sthSelected
    
    return true if sthSelected
    notifier.show 'n-wsb-no-selection'
    return false

  ###
    Launch QuickTrial demo on click
  ###
  $('#btn-launch-demo').on 'click', (event) ->
    event.stopImmediatePropagation()
    m = $(this).closest('.modal').eq(0)
    m.modal 'hide'
    $('#m-demo').modal 'show'
    return true

  ###
    Step 2 of defining a new sektion
  ###

  $('#m-new-sk-1').on 'click', 'button', (event) ->
    return false if $(this).hasClass 'disabled'
    return true if $(this).attr('type') is 'submit'

    parent = $(this).closest '.modal'
    $(parent).modal 'hide'
    id = $(this).attr 'id'
    $('#m-new-sk-2').modal('show') if id is 'btn-add-now'
    event.stopImmediatePropagation()
    return true

  ###
    Launch Quick Trial explanatory dialog
  ###
  $('#btn-whatisthis').on 'click', (event) ->
    event.stopPropagation()
    $('#m-demo').modal 'hide'
    $('#m-demo-intro').modal 'show'
    return true

  ###
    [qzb]: When a filter is clicked
  ###
  $('#form-qzb').on 'click', '#lnk-qzb-fav, #lnk-qzb-selected, #lnk-qzb-showall', (event) ->
    id = $(this).attr 'id'
    switch id
      when 'lnk-qzb-fav'
        selection = 'Favourites'
        klass = 'fav'
      when 'lnk-qzb-selected'
        selection = 'Selected'
        klass = 'selected'
      when 'lnk-qzb-showall'
        selection = 'Show All'
        klass = 'none'

    # Step 1: Visual reminder of last filter selected
    filter = $(this).closest('ul').next()
    filter.text selection

    # Step 2: Update [filter] attribute on #qzb-questions. The attribute 
    # is set when filter selection is changed and it determines which 
    # questions are shown 

    root = $('#qzb-questions')
    root.attr 'filter', klass
    sieve.through root
    return true
