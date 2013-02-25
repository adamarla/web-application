
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
      clickFirst = true
      karo.empty target
    else if url.match(/sektion\/students/)
      if json.context is 'deepdive'
        target = $('#pane-dive-3')
        target.empty()
      else
        target = $("#lp-sektion-#{json.sektion}")
      parentKey = "students"
      childKey = 'student'
      wsDeepdive.students json
    else if url.match(/teacher\/courses/)
      target = $('#pane-qzb-courses')
      parentKey = 'courses'
      childKey = 'course'
    else if url.match(/qzb\/echo/)
      next = if json.context is 'qzb' then 'tab-qzb-questions' else 'tab-editqz-3'
      karo.tab.enable next

      root = "##{json.context}-questions"
      leftTabs.create root, json, {
        klass : {
          ul : "span4 nopurge-ever",
          content : "span7",
          div : "multi-select"
        },
        data : {
          url : "questions/on?id=:id&context=#{json.context}",
          'panel-url' : "question/preview?id=:id"
        },
        id : {
          div : "#{json.context}-pick"
        }
      }
      return true
    else if url.match(/questions\/on/)
      topic = json.topic
      target = $("##{json.context}-pick-#{topic}")
      parentKey = 'questions'
      childKey = 'datum'
    else if url.match(/quiz\/testpapers/)
      target = $("#pane-wsb-existing")
      parentKey = "testpapers"
      childKey = "testpaper"
      menu = 'per-ws'
      clickFirst = true
    else if url.match(/ws\/summary/)
      target = $("#pane-tc-rc-2")
      parentKey = "root"
      childKey = "datum"
      wsSummary json
    else if url.match(/teacher\/sektions/)
      target = $('#pane-dive-1')
      parentKey = 'sektions'
      childKey = 'sektion'
    else if url.match(/vertical\/topics/)
      if json.context isnt 'deepdive'
        target = $("##{json.context}-#{json.vertical}")
      else
        target = $('#deepdive-topics')
      parentKey = 'topics'
      childKey = 'topic'
    else if url.match(/sektion\/proficiency/)
      wsDeepdive.loadProficiencyData json
    else if url.match(/overall\/proficiency/)
      wsDeepdive.byStudent json
    else if url.match(/quiz\/questions/)
      target = $('#editqz-1')
      parentKey = 'questions'
      childKey = 'datum'
    else
      matched = false

    if target? and target.length isnt 0
      # karo.empty target
      line.write(target, m[childKey], menu) for m in json[parentKey]

      # Disable any newly added .single-line if its marker in json.disable
      if json.disable? # => an array of indices
        j = target.children('.single-line')
        for m in json.disable
          k = j.filter("[marker=#{m}]")[0]
          $(k).addClass 'disabled' if k?

      # Enable / disable paginator as needed 
      if json.last_pg?
        pagination.enable pgn, json.last_pg
        # pagination.url.set pgn, pgnUrl

      # Auto-click first line - if needed
      target.children('.single-line').eq(0).click() if clickFirst
      

    e.stopPropagation() if matched is true
    return true
