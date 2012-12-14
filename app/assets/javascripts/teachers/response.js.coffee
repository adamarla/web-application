
############################################################################
## Bootstrap 
############################################################################

jQuery ->

  $('#lp').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    parentKey = null
    childKey = null
    menu = null # ID of contextual menu to attach w/ each .single-line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#lp-paginator')
    clickFirst = false # whether or not to auto-click the first .single-line

    if url.match(/quizzes\/list/)
      target = $('#lp-quizzes')
      parentKey = 'quizzes'
      childKey = 'quiz'
      menu = "#per-quiz"
      pgnUrl = "quizzes/list"
      clickFirst = true
    else if url.match(/sektion\/students/)
      target = $("#lp-sektion-#{json.sektion}")
      parentKey = "students"
      childKey = 'student'

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    if target.length isnt 0
      target.empty()
      for m in json[parentKey]
        line.write target, m[childKey], menu

      # Enable / disable paginator as needed 
      if pgnUrl? and json.last_pg?
        pagination.enable pgn, json.last_pg
        pagination.url.set pgn, pgnUrl

      # Auto-click first line - if needed
      target.children('.single-line').eq(0).click() if clickFirst
      

    e.stopPropagation() if matched is true
    return true
