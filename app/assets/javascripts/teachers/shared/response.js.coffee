
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
    clickFirst = false # whether or not to auto-click the first .line
    lesson = null
    buttons = null

    if url.match(/quizzes\/list/)
      key = 'quizzes'
      clickFirst = true
      indie = if json.indie? then json.indie else false

      if indie 
        target = $('#pane-my-quizzes')
      else
        target = $('#pane-exb-quizzes')
        menu = "per-quiz"
      karo.empty target
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
          div : "multi-select paginator"
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

    else if url.match(/vertical\/topics/)
      if json.context isnt 'deepdive'
        target = $("##{json.context}-#{json.vertical}")
        milestone = if json.context is 'qzb' then 3 else 4
        lesson = "#{json.context}-milestone-#{milestone}"
      else
        target = $('#deepdive-topics')
      key = 'topics'

    else if url.match(/quiz\/questions/)
      target = $('#editqz-1')
      key = 'questions'
      lesson = 'editqz-milestone-2'

    else if url.match(/quiz\/build/)
      lesson = 'qzb-milestone-7'
      monitor.add json
      $('#lnk-existing-quiz').click()
      notifier.show 'n-queued', json

    else if url.match(/quiz\/edit/)
      monitor.add json
      notifier.show 'n-edit-quiz', json

    else if url.match(/like/)
      pane = $('#qzb-questions').find('.tab-pane.active').eq(0)
      question = pane.find(".line[marker=#{json.favourite.id}]")[0]
      $(question).addClass 'fav' if question?
      notifier.show 'n-favourited'

    else if url.match(/ping\/queue/)
      bell.update json
      # enable the newly built quizzes 
      j = if json.indie then $('#pane-my-quizzes') else $('#pane-exb-quizzes')
      list = j.children()
      for id in json.enable
        quiz = list.filter("[marker=#{id}]")[0]
        $(quiz).removeClass('disabled') if quiz?
      # demo.update json

    else if url.match(/quiz\/mass_assign/) || url.match(/ping\/exam/)
      monitor.add json
      if json.meta?
        m = $('#m-exb-deadlines')
        eid = json.meta['id']
        f = m.find('form')
        z.options[0].selected = true for z in f.find('select') # select default blank option
        f.attr 'action', "set/deadlines?id=#{eid}"
        m.modal 'show'

    else if url.match(/exam\/disputes/)
      isPending = if json.pending? then true else false 
      clickFirst = true
      menu = 'm-dispute'
      if isPending
        target = $('#pane-pending-disputes')
        key = 'pending'
      else
        target = $('#pane-resolved-disputes')
        key = 'resolved'
      karo.empty target
    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst

    # If in tutorial mode, then start the next tutorial - if any
    tutorial.start lesson if lesson?

    e.stopPropagation() if matched is true
    return true
