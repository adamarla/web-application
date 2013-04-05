
############################################################################
## Bootstrap 
############################################################################

jQuery ->

  $('#m-suggestion-upload').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    if url.match(/teacher\/upload_suggestion/)
      if json.status == "duplicate"
        $('#m-suggestion-upload #ackblurb p').html(json.message) 
        $('#m-suggestion-upload #ackblurb').show()
      else
        $('#m-suggestion-upload #suggestiondoc').hide()
        $('#m-suggestion-upload #instruction').hide()
        $('#m-suggestion-upload #ackblurb p').html(json.message) 
        $('#m-suggestion-upload #ackblurb').show()

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
    lesson = null
    buttons = null

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
      else if json.context is 'list'
        target = $('#enrolled-students')
        karo.empty target
      else
        target = $('#wsb-sektions')
        lesson = 'wsb-milestone-3'

      parentKey = "students"
      childKey = 'student'
      wsDeepdive.students json
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
          content : "span7",
          div : "multi-select pagination"
        },
        data : {
          url : "questions/on?id=:id&context=#{json.context}",
          'panel-url' : "question/preview?id=:id&context=#{json.context}"
        },
        id : {
          div : "#{json.context}-pick",
          ul : "#{json.context}-ul-milestone-4",
          root : "#{json.context}-div-milestone-5"
        }
      }
      if tutorial.active
        tutorial.start lesson if lesson?
      return true
    else if url.match(/questions\/on/)
      topic = json.topic
      target = $("##{json.context}-pick-#{topic}")
      parentKey = 'questions'
      childKey = 'datum'
      lesson = if json.context is 'qzb' then 'qzb-milestone-5' else 'editqz-milestone-6'
      buttons = 'icon-plus-sign'
    else if url.match(/quiz\/testpapers/)
      target = $("#pane-wsb-existing")
      parentKey = "testpapers"
      childKey = "testpaper"
      menu = 'per-ws'
      clickFirst = true
      lesson = 'publish-milestone-2'
    else if url.match(/ws\/summary/)
      target = $("#pane-tc-rc-2")
      parentKey = "root"
      childKey = "datum"
      wsSummary json
    else if url.match(/teacher\/sektions/)
      if json.context is 'list'
        target = $('#pane-mng-sektions-1')
        lesson = 'mng-sektions-milestone-2'
      else
        target = $('#pane-dive-1')

      parentKey = 'sektions'
      childKey = 'sektion'
      clickFirst = true
    else if url.match(/vertical\/topics/)
      if json.context isnt 'deepdive'
        target = $("##{json.context}-#{json.vertical}")
        milestone = if json.context is 'qzb' then 3 else 4
        lesson = "#{json.context}-milestone-#{milestone}"
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
      lesson = 'editqz-milestone-2'
    else if url.match(/add\/sektion/)
      target = $('#pane-mng-sektions-1')
      parentKey = 'sektion'
      childKey = 'new'
      $('#m-add-sektion').modal 'hide'
      lesson = 'mng-sektions-milestone-3'
    else if url.match(/ping\/sektion/)
      tab = $('#mng-sektions').find("a[marker=#{json.sektion.id}]")[0]
      karo.tab.enable tab if tab?
    else if url.match(/build_quiz/)
      lesson = 'qzb-milestone-7'
      monitor.add json
      $('#lnk-existing-quiz').click()
    else if url.match(/update\/sektion/)
      target = $('#enrolled-students')
    else
      matched = false

    if target? and target.length isnt 0
      writeData = if (parentKey? and childKey?) then true else false

      # Enable / disable paginator as needed 
      if json.last_pg?
        pagination.enable pgn, json.last_pg

        ###
          this next bit of code is done only for teachers and in a very specific 
          contexts - picking questions to add to a quiz - either when its 
          first being built or when its being edited subsequently

          the issue is that we would like pagination with multi-select. 
          with pagination, we can break a long list down into manageable chunks
          But multi-select requires that we retain any previously loaded data 
          and selections
        ###
        if target.hasClass 'pagination'
          if json.pg?
            page = target.children("div[page='#{json.pg}']")
            $("<div page=#{json.pg} class='multi-select purge-skip'></div>").appendTo target if page.length is 0
            target = target.children("div[page='#{json.pg}']").eq(0)
            $(m).addClass 'hide' for m in target.siblings()
            target.removeClass 'hide'
            writeData = target.children().length is 0

      # Render the returned JSON - in columns if so desired
      lines.columnify target, json[parentKey], childKey, menu, buttons if writeData
      # line.write(target, m[childKey], menu, buttons) for m in json[parentKey] if writeData

      # Disable / hide any .single-line whose marker is in json.[disabled, hide]
      for m in ['disabled', 'hide']
        continue unless json[m]
        j = target.find('.single-line')
        for k in json[m]
          l = j.filter("[marker=#{k}]")[0]
          $(l).addClass(m) if l?

      # Auto-click first line - if needed
      target.children('.single-line').filter(":not([class~='disabled'])").eq(0).click() if clickFirst
      
    # If in tutorial mode, then start the next tutorial - if any
    if tutorial.active
      tutorial.start lesson if lesson?
    e.stopPropagation() if matched is true
    return true
