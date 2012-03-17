
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
    json = $.parseJSON xhr.responseText
    if settings.url.match(/schools\/list/)
      coreUtil.interface.displayJson json.schools, '#schools-summary', 'school'
    else if settings.url.match(/courses\/list/)
      coreUtil.interface.displayJson json.courses, '#courses-summary', 'course', {radio:true, button:true}
      swissKnife.setButtonCaption '#courses-summary', 'edit'
    else if settings.url.match(/questions\/list/)
      # flipchart initialized in core/behaviour 
      coreUtil.interface.displayJson json.questions, '#examiner-untagged', 'question'
    else if settings.url.match(/verticals\/list/)
      coreUtil.mnmlists.redistribute true
      coreUtil.mnmlists.customize 'vertical'
      coreUtil.mnmlists.customize 'topic'
      coreUtil.mnmlists.attach 'vertical', '#vertical-selection'
      coreUtil.mnmlists.attach 'topic', '#topic-selection'
    else if settings.url.match(/examiner\/pending_quizzes/)
      coreUtil.interface.displayJson json.quizzes, '#pending-quizzes', 'quiz'
      #coreUtil.dom.mkListFromJson json.pending, '#list-ungraded-responses', 'pending'
      canvas.loadNth 0
    else if settings.url.match(/quiz\/pending_pages/)
      coreUtil.interface.displayJson json.pages, '#pending-pages', 'page'
    else if settings.url.match(/quiz\/pending_scans/)
      adminUtil.buildPendingScanList json.scans
      canvas.loadNth 0

    return true
      

  ###
    AJAX successes the middle-panel is supposed to respond to.
  ###

  $('#middle-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/yardstick\.json/) or
              settings.url.match(/teachers\/list/) or
              settings.url.match(/school\/sektions/) or
              settings.url.match(/course\/coverage/) or
              settings.url.match(/vertical/) # POST-request
    return if matched is null

    json = $.parseJSON xhr.responseText
    onDisplay = $(this).children().first()
    e.stopPropagation()

    switch matched.pop()
      when 'teachers/list'
        coreUtil.interface.displayJson json.teachers, '#teachers-list', 'teacher', {radio:true,button:true}
        swissKnife.setButtonCaption '#teachers-list', 'edit'
      when 'school/sektions'
        if onDisplay.attr('id') is 'new-student'
          select = onDisplay.find 'form select:first' # the first select is for sektions 
          coreUtil.dom.loadJsonToSelect select, json.sektions, 'sektion'
        else
          coreUtil.interface.displayJson json.sektions, '#studygroups-radiolist', 'sektion'
      when 'yardstick.json'
        coreUtil.dom.unsetCheckboxesIn '#edit-yardstick'
        coreUtil.forms.loadJson '#edit-yardstick > form:first', json.yardstick
        $('#edit-yardstick').dialog 'open'
      when 'course/coverage'
        coreUtil.mnmlists.redistribute json.verticals
        coreUtil.mnmlists.customize 'vertical'

        target = $('#vertical-selection')
        $('#vertical-selected-list').insertAfter target.children('legend').eq(0)
        $('#vertical-deselected-list').insertAfter target.children('legend').eq(1)

        adminUtil.buildSyllabiEditForm json.verticals
      when 'vertical'
        if onDisplay.attr('id') is 'new-topics'
          select = onDisplay.find 'form select:first'
          coreUtil.dom.loadJsonToSelect select, json.verticals, 'vertical'

  ###
    AJAX successes the right-panel is supposed to respond to.
  ###

  $('#right-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teachers\/roster/) or
              settings.url.match(/school\/unassigned-students/) or
              settings.url.match(/sektions\/students/) or
              settings.url.match(/verticals\/list/) or
              settings.url.match(/school\.json/) or
              settings.url.match(/examiners\/list/)
    return if matched is null
  
    e.stopPropagation()
    json = $.parseJSON xhr.responseText

    switch matched.pop()
      when 'teachers/roster'
        here = $('#edit-student-klass-mapping').children 'form:first'
        coreUtil.interface.displayJson json.sektions, here, 'sektion', {checkbox:true}
      when 'school/unassigned-students', 'sektions/students'
        here = $('#student-list').children 'form:first'
        coreUtil.interface.displayJson json.students, here, 'student', {checkbox:true}
      when 'school.json'
        coreUtil.forms.loadJson $('#edit-school').children('form:first'), json.school
      when 'verticals/list'
        # Customize swiss-knives within topics to include just one enabled radio-button
        topics = $('#topic-list')
        for vertical in topics.find 'div[marker]'
          for e in $(vertical).children()
            swissKnife.customize $(e), {radio:true}, true
      when 'examiners/list'
        here = $('#examiners-list')
        coreUtil.interface.displayJson json.examiners, here, 'examiner', {}

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
