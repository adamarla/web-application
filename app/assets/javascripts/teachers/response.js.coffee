
############################################################################
## Bootstrap 
############################################################################

jQuery ->

  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .line
    lesson = null
    buttons = null

    if url.match(/quizzes\/list/)
      target = $('#pane-wsb-quizzes')
      key = 'quizzes'
      menu = "per-quiz"
      clickFirst = true
      karo.empty target
    else if url.match(/sektion\/students/)
      if json.context is 'deepdive'
        target = $('#pane-dive-3')
        target.empty()
        wsDeepdive.students json
      else if json.context is 'list'
        target = $('#enrolled-students')
        karo.empty target
      else
        target = $('#wsb-sektions')
        lesson = 'wsb-milestone-3'
      key = "students"

    else if url.match(/share\/quiz/)
      $('#m-share-quiz').modal 'hide'
      if json.status is 'missing'
        notifier.show 'n-share-missing-teacher'
      else if json.status is 'error'
        notifier.show 'n-share-error'
      else if json.status is 'donothing'
        notifier.show 'n-share-already'
      else 
        notifier.show 'n-share-success'

    else if url.match(/qzb\/echo/)
      if json.context is 'qzb'
        next = 'tab-qzb-2'
      else
        next = 'tab-editqz-3'
        lesson = 'editqz-milestone-5'

      karo.tab.enable next

      root = "##{json.context}-questions"
      leftTabs.create root, json, {
        klass : {
          ul : "span4",
          content : "span7 scroll",
          div : "multi-select pagination"
        },
        data : {
          url : "questions/on?id=:id&context=#{json.context}",
          'url-panel' : "question/preview?id=:id&context=#{json.context}"
        },
        id : {
          div : "#{json.context}-pick",
          ul : "#{json.context}-ul-milestone-4",
          root : "#{json.context}-div-milestone-5"
        }
      }

      tutorial.start lesson if lesson?
      return true
    else if url.match(/questions\/on/)
      topic = json.topic
      target = $("##{json.context}-pick-#{topic}")
      key = 'questions'
      menu = 'per-question'
      lesson = if json.context is 'qzb' then 'qzb-milestone-5' else 'editqz-milestone-6'
      buttons = 'icon-plus-sign'
    else if url.match(/quiz\/exams/)
      target = $("#pane-wsb-existing")
      key = "exams"
      menu = 'per-ws'
      clickFirst = true
      lesson = 'publish-milestone-2'
    else if url.match(/exam\/summary/)
      target = $("#pane-tc-rc-2")
      key = "root"
      wsSummary json
      $('#lnk-rc-download')[0].setAttribute 'href', "ws/report_card?id=#{json.a}&format=csv"
    else if url.match(/teacher\/sektions/)
      if json.context is 'list'
        target = $('#pane-mng-sektions-1')
        lesson = 'mng-sektions-milestone-2'
        menu = 'per-sektion'
        clickFirst = true
      else
        target = $('#pane-dive-1')

      key = 'sektions'
    else if url.match(/vertical\/topics/)
      if json.context isnt 'deepdive'
        target = $("##{json.context}-#{json.vertical}")
        milestone = if json.context is 'qzb' then 3 else 4
        lesson = "#{json.context}-milestone-#{milestone}"
      else
        target = $('#deepdive-topics')
      key = 'topics'
    else if url.match(/sektion\/proficiency/)
      wsDeepdive.loadProficiencyData json
    else if url.match(/overall\/proficiency/)
      wsDeepdive.byStudent json
    else if url.match(/quiz\/questions/)
      target = $('#editqz-1')
      key = 'questions'
      lesson = 'editqz-milestone-2'
    else if url.match(/add\/sektion/)
      lesson = 'mng-sektions-milestone-3'
      $('#m-new-sk-1').modal 'hide'
      $('#lnk-mng-sektions').trigger 'click'

      # [102]: Add the new sektion as a left-tab so that teachers can start making 
      # worksheets without having to reload the site
      leftTabs.add '#sektions-tab', json, {
        shared : 'wsb-sektions',
        data : {
          url : "sektion/students.json?id=:id&context=wsb&quiz=:prev",
          prev : "tab-wsb-quizzes"
        }
      }
    else if url.match(/ping\/sektion/)
      tab = $('#mng-sektions').find("a[marker=#{json.sektion.id}]")[0]
      karo.tab.enable tab if tab?
    else if url.match(/quiz\/build/)
      lesson = 'qzb-milestone-7'
      monitor.add json
      $('#lnk-existing-quiz').click()
      notifier.show 'n-queued', json
    else if url.match(/quiz\/assign/)
      monitor.add json
      notifier.show 'n-queued', json
    else if url.match(/quiz\/edit/)
      monitor.add json
      notifier.show 'n-edit-quiz', json
    else if url.match(/update\/sektion/)
      target = $('#enrolled-students')
    else if url.match(/like/)
      pane = $('#qzb-questions').find('.tab-pane.active').eq(0)
      question = pane.find(".line[marker=#{json.favourite.id}]")[0]
      $(question).addClass 'fav' if question?
      notifier.show 'n-favourited'
    else if url.match(/enroll\/named/)
      $('#m-new-sk-2').modal 'hide'
      notifier.show 'n-enrolled', json
    else if url.match(/ping\/queue/)
      # enable the newly built quizzes 
      list = $('#pane-wsb-quizzes').children()
      for id in json.enable
        quiz = list.filter("[marker=#{id}]")[0]
        $(quiz).removeClass('disabled') if quiz?
      # demo.update json
    else if url.match(/prefab/)
      monitor.add json
      x = $('#m-demo').find("li[marker=#{json.timer.on}]").eq(0)
      watch = x.children('.stopwatch')[0]
      stopWatch.start watch, parseInt(json.timer.for)
      $('#lnk-existing-quiz').click()
    else if url.match(/preview\/names/)
      target = $('#new-sk-students')
      lines.columnify target, json.names
      for m in target.find '.line'
        $(m).addClass 'disabled'
        cb = $(m).children("[type='checkbox']").eq(0)
        cb.prop 'checked', true
        cb.attr 'value', cb.siblings('.text').eq(0).text()
      return true
    else if url.match(/course\/new/)
      $('#m-add-course').modal 'hide'
    else if url.match(/course\/all/)
      target = $('#pane-online-courses')
      key = 'courses'
    else if url.match(/milestone\/load/) || url.match(/available\/assets/)
      target = $('#lessons-and-quizzes')
      key = 'assets'
      menu = 'per-asset'
    else if url.match(/attach_detach_asset/)
      $('#mng-assets').modal 'hide'
    else if url.match(/quiz\/mass_assign/)
      monitor.add json
    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst, pgn, pgnUrl

    # If in tutorial mode, then start the next tutorial - if any
    tutorial.start lesson if lesson?

    e.stopPropagation() if matched is true
    return true
