
############################################################################
## Bootstrap 
############################################################################

jQuery ->

  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    parentKey = null
    childKey = null
    menu = null # ID of contextual menu to attach w/ each .single-line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .single-line

    if url.match(/quizzes\/list/)
      target = $('#pane-wsb-quizzes')
      parentKey = 'quizzes'
      childKey = 'quiz'
      menu = "per-quiz"
      # pgnUrl = "quizzes/list"
      clickFirst = true
    else if url.match(/sektion\/students/)
      target = $("#lp-sektion-#{json.sektion}")
      parentKey = "students"
      childKey = 'student'
    else if url.match(/teacher\/courses/)
      target = $('#pane-qzb-courses')
      parentKey = 'courses'
      childKey = 'course'
    else if url.match(/course\/topics_in/)
      target = $("#vert-#{json.vertical}")
      parentKey = 'topics'
      childKey = 'topic'
    else if url.match(/qzb\/echo/)
      karo.tab.enable 'tab-qzb-questions'
      leftTabs.create '#qzb-questions', json, {
        klass : {
          ul : "span3 nopurge-on-show",
          content : "span8",
          div : "writeonce"
        },
        data : {
          ajax : "course/questions?id=:prev&topic=:id"
          prev : "tab-qzb-courses"
        }
      }
      return true
    else if url.match(/course\/questions/)
      topic = json.topic
      target = $("#dyn-tab-#{topic}")
      parentKey = 'questions'
      childKey = 'question'
    else if url.match(/quiz\/testpapers/)
      target = $("#pane-wsl")
      parentKey = "testpapers"
      childKey = "testpaper"
      menu = 'per-ws'
      clickFirst = true

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    if target? and target.length isnt 0
      purge = if target.hasClass('writeonce') then target.children().length is 0 else true
      if purge
        karo.empty target
        line.write(target, m[childKey], menu) for m in json[parentKey]

      # Enable / disable paginator as needed 
      if json.last_pg?
        pagination.enable pgn, json.last_pg
        # pagination.url.set pgn, pgnUrl

      # Auto-click first line - if needed
      target.children('.single-line').eq(0).click() if clickFirst
      

    e.stopPropagation() if matched is true
    return true
