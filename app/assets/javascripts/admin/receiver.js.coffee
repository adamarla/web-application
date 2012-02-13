
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
    matched = settings.url.match(/schools\/list/) or
              settings.url.match(/courses\/list/) or
              settings.url.match(/questions\/list/) or
              settings.url.match(/macros\/list/) or
              settings.url.match(/examiner\/pending_quizzes/) or
              settings.url.match(/examiner\/pending_pages/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'schools/list'
        coreUtil.interface.displayJson json.schools, '#schools-summary', 'school'
      when 'courses/list'
        coreUtil.interface.displayJson json.courses, '#courses-summary', 'course', {radio:true, button:true}
        swissKnife.setButtonCaption '#courses-summary', 'edit'
      when 'questions/list'
        # flipchart initialized in core/behaviour 
        coreUtil.interface.displayJson json.questions, '#examiner-untagged', 'question'
      when 'macros/list'
        coreUtil.mnmlists.redistribute true
        coreUtil.mnmlists.customize 'macro'
        coreUtil.mnmlists.customize 'micro'

        coreUtil.mnmlists.attach 'macro', '#macro-selection'
        coreUtil.mnmlists.attach 'micro', '#micro-selection'
      when 'examiner/pending_quizzes'
        coreUtil.interface.displayJson json.quizzes, '#pending-quizzes', 'quiz'
      when 'examiner/pending_pages'
        coreUtil.interface.displayJson json.pages, '#pending-pages', 'page'

  ###
    AJAX successes the middle-panel is supposed to respond to.
  ###

  $('#middle-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/yardstick\.json/) or
              settings.url.match(/teachers\/list/) or
              settings.url.match(/school\/sektions/) or
              settings.url.match(/course\/coverage/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    onDisplay = $(this).children().first()


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
        ###
        coreUtil.dom.unsetCheckboxesIn '#edit-yardstick'
        coreUtil.forms.loadJson '#edit-yardstick > form:first', json.yardstick
        $('#edit-yardstick').dialog 'open'
        ###
      when 'course/coverage'
        coreUtil.mnmlists.redistribute json.macros
        coreUtil.mnmlists.customize 'macro'

        target = $('#macro-selection')
        $('#macro-selected-list').insertAfter target.children('legend').eq(0)
        $('#macro-deselected-list').insertAfter target.children('legend').eq(1)

        adminUtil.buildSyllabiEditForm json.macros

  ###
    AJAX successes the right-panel is supposed to respond to.
  ###

  $('#right-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teachers\/roster/) or
              settings.url.match(/school\/unassigned-students/) or
              settings.url.match(/sektions\/students/) or
              settings.url.match(/macros\/list/) or
              settings.url.match(/school\.json/)
    return if matched is null

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
      when 'macros/list'
        # Customize swiss-knives within microTopics to include just one enabled radio-button
        microTopics = $('#micro-topic-list')
        for macro in microTopics.find 'div[marker]'
          for e in $(macro).children()
            swissKnife.customize $(e), {radio:true}, true


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
    for slot in json.slots
      $("<li class='code'>#{slot}</li>").appendTo target

    target.fadeIn('slow')
    return true
