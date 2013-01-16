
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
          ul : "span4 nopurge-ever",
          content : "span7",
          div : "multi-select"
        },
        data : {
          url : "course/questions?id=:prev&topic=:id"
          prev : "tab-qzb-courses",
          'panel-url' : "question/preview?id=:id"
        }
      }
      return true
    else if url.match(/course\/questions/)
      topic = json.topic
      target = $("#dyn-tab-#{topic}")
      parentKey = 'questions'
      childKey = 'question'
    else if url.match(/quiz\/testpapers/)
      target = $("#pane-wsb-existing")
      parentKey = "testpapers"
      childKey = "testpaper"
      menu = 'per-ws'
      clickFirst = true
    else if url.match(/ws\/summary/)
      target = $("#pane-tc-rc-2")
      parentKey = "students"
      childKey = "student"

      # Draw the summary chart 
      chart.initialize()
      chart.series.define json.students, 'student', 'marks', 'y' # 0
      chart.series.define json.students, 'student', 'mean', 'y' # 1
      chart.series.define json.students, 'student', 'marks', 'y', chart.filter.geqZero # 2, overwrites some of #0
      # chart.series.link 0,1 # 3

      chart.series.customize 0, {
        color: color.blue,
        points : { show:true, radius: 5, fill: 0}
      }
      chart.series.customize 1, {
        color: color.orange,
        points : { show:true, radius: 2, fillColor: color.orange },
        lines : { show: false },
        label : "Avg = #{json.students[0].student.mean}"
      }
      chart.series.customize 2, {
        color: color.red,
        points: { show: true, radius: 5, fill: 0 },
        label : "No Scans"
      }
      chart.series.customize 3, {
        color: color.blue,
        points: {show: false},
        lines: {show: true, lineWidth: 1}
      }
      chart.draw {
        xaxis : { min: 0, max: json.students[0].student.max, position: "top"},
        yaxis: { ticks: json.students.length },
        legend: { show: true, position:"ne", backgroundColor: "transparent" }
      }
      chart.series.label 0, json.students, 'student'
    else if url.match(/feedback/)
      type = url.substr(url.lastIndexOf("=") + 1)
      target = $("#pane-#{type}")
      parentKey = "rqms"
      childKey = "rqm"

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    if target? and target.length isnt 0
      # karo.empty target
      line.write(target, m[childKey], menu) for m in json[parentKey]

      # Enable / disable paginator as needed 
      if json.last_pg?
        pagination.enable pgn, json.last_pg
        # pagination.url.set pgn, pgnUrl

      # Auto-click first line - if needed
      target.children('.single-line').eq(0).click() if clickFirst
      

    e.stopPropagation() if matched is true
    return true
