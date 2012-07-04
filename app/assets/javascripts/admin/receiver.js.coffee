
###
   This is a bloody important file.

   Everytime there is an AJAX request, and therefore an AJAX response,
   the response needs to be captured and if something needs to be done
   by an element, then that something must be done

   It is this internal wiring that is defined here.

   Broadly speaking, rather than attach event handlers to, say, a radio
   button - of which there would be many - we prefer to attach one
   event handler to a DOM element high up in the DOM hierarchy. In the
   new jQuery ( > 1.7 ), events percolate up the DOM and are captured
   by the first element tasked to do so. The advantage is a leaner in-memory
   object model.
###

jQuery ->
  ###
    AJAX successes the side-panel is supposed to respond to.
    Note that JS reg-exp matching returns an array of matches - not
    the first matching sub-string. Hence, we pop the first match.
    That's ok because we know that if there were a match, then there
    would be only one
  ###

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    url = settings.url
    json = $.parseJSON xhr.responseText
    matched = true

    if url.match(/schools\/list/)
      coreUtil.interface.displayJson json.schools, '#schools-summary', 'school'
    else if url.match(/courses\/list/)
      coreUtil.interface.displayJson json.courses, '#courses-summary', 'course', {radio:true, button:true}
      swissKnife.setButtonCaption '#courses-summary', 'edit'
    else if url.match(/questions\/list/)
      # flipchart initialized in core/behaviour 
      coreUtil.interface.displayJson json.questions, '#examiner-untagged', 'question'
    else if url.match(/examiner\/pending_quizzes/)
      coreUtil.interface.displayJson json.quizzes, '#pending-quizzes', 'quiz'
      #coreUtil.dom.mkListFromJson json.pending, '#list-ungraded-responses', 'pending'
      canvas.loadNth 0
    else if url.match(/quiz\/pending_pages/)
      coreUtil.interface.displayJson json.pages, '#pending-pages', 'page'
    else if url.match(/quiz\/pending_scans/)
      adminUtil.buildPendingScanList json.scans
      canvas.loadNth 0
    else if url.match(/examiner\/pending_suggestions/)
      coreUtil.interface.displayJson json.suggestions, '#suggestions', 'suggestion', radio:true
    else if url.match(/suggestion\/display/)
      preview.loadJson json, 'locker'
    else if url.match(/suggestion\/block_db_slots/)
      target = $('#created-slots')
      target.hide()
      target.empty() # purge any old summary from previous call
      for slot in json.slots
        $("<li class='code'>#{slot}</li>").appendTo target
      target.fadeIn('slow')
      flipchart.rewind '#unexamined-suggestions'      
    else if url.match(/question\?/) # rewind flipchart on successful question tagging
      child = $(this).children().eq(0)
      return if child.attr('id') isnt 'workbenches-summary'
      flipchart.rewind '#workbenches-summary'
    else if url.match(/course\/coverage/)
      here = $('#edit-course-topics')
      # we will get the full list of topics irrespective of whether or not a topic
      # is covered in the said course or not. Hence, we must empty out the .scroll-contents
      # and recreate the topic list afresh 

      for m in here.children('.scroll-content')
        $(m).empty()
      scroll.loadJson json.topics, 'topic', here, null, scroll.having.select
    else
      matched = false

    return true
      

  ###
    AJAX successes the middle-panel is supposed to respond to.
  ###

  $('#middle-panel').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    onDisplay = $(this).children().first()
    matched = true
    url = settings.url

    if url.match(/teachers\/list/)
      coreUtil.interface.displayJson json.teachers, '#teachers-list', 'teacher', {radio:true,button:true}
      swissKnife.setButtonCaption '#teachers-list', 'edit'
    else if url.match(/school\/sektions/)
      if onDisplay.attr('id') is 'new-student'
        select = onDisplay.find 'form select:first' # the first select is for sektions 
        coreUtil.dom.loadJsonToSelect select, json.sektions, 'sektion'
      else
        coreUtil.interface.displayJson json.sektions, '#studygroups-radiolist', 'sektion'
    else if url.match(/yardstick.json/)
      coreUtil.dom.unsetCheckboxesIn '#edit-yardstick'
      coreUtil.forms.loadJson '#edit-yardstick > form:first', json.yardstick
      $('#edit-yardstick').dialog 'open'
    else if url.match(/verticals\/list/)
      for here,j in ['#tag-question-topics', '#edit-course-topics', '#define-course-topics']
        scroll.initialize json.verticals, 'vertical', $(here)
        $(here).accordion scroll.options
      m = $('#new-topics').find('select').eq(0)
      coreUtil.dom.loadJsonToSelect m, json.verticals, 'vertical'
    else if url.match(/vertical$/) # /vertical POST request response. Notice the regexp strict match
      $.get "verticals/list.json"
    else
      matched = false

    e.stopPropagation() if matched is true
    return true

  ###
    AJAX successes the right-panel is supposed to respond to.
  ###

  $('#right-panel').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    matched = true
    url = settings.url

    if url.match(/teachers\/roster/)
      here = $('#edit-student-klass-mapping').children 'form:first'
      coreUtil.interface.displayJson json.sektions, here, 'sektion', {checkbox:true}
    else if url.match(/school\/unassigned-students/) or url.match(/sektions\/students/)
      here = $('#student-list').children 'form:first'
      coreUtil.interface.displayJson json.students, here, 'student', {checkbox:true}
    else if url.match(/school/)
      coreUtil.forms.loadJson $('#edit-school').children('form:first'), json.school
    else if url.match(/vertical\/topics/)
      for here,j in ['#tag-question-topics', '#define-course-topics']
        if j isnt 0
          scroll.loadJson json.topics, 'topic', $(here), null, scroll.having.select
        else
          scroll.loadJson json.topics, 'topic', $(here), null, scroll.having.radio
    else
      matched = false

    e.stopPropagation() if matched is true
    return true

  ###
    AJAX successes the right-panel is supposed to respond to.
  ###

  ###
    Miscellaneous event captures 
  ###

  $('#teachers-list').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teacher\/load/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'teacher/load'
        form = $('#edit-teacher > form:first')
        coreUtil.forms.loadJson form, json.teacher
        coreUtil.forms.modifyAction form, "/teacher.json?id=#{json.teacher.id}", 'put'
        $('#edit-teacher').dialog('open')
    return true


  $('#courses-summary').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/course\/profile/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'course/profile'
        form = $('#edit-course > form:first')
        coreUtil.forms.loadJson form, json.course
        coreUtil.forms.modifyAction form, "course.json?id=#{json.course.id}", 'put'
        $('#edit-course').dialog('open')
    return true

  $('#block-db-operation-summary').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/examiner\/block_db_slots/)
    return if matched is null

    e.stopPropagation()
    json = $.parseJSON xhr.responseText
    target = $('#created-slots')
    target.hide()
    target.empty() # purge any old summary from previous call
    for slot in json.slots
      $("<li class='code'>#{slot}</li>").appendTo target

    target.fadeIn('slow')
    return true
