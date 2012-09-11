
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
      coreUtil.interface.displayJson json.questions, '#examiner-untagged', 'question', {radio:true}, true
    else if url.match(/examiner\/pending_quizzes/)
      coreUtil.interface.displayJson json.quizzes, '#pending-quizzes', 'quiz', {radio:true, button:true}
      swissKnife.setButtonCaption '#pending-quizzes', 'answer-key'
      for m in $('#pending-quizzes').find '.swiss-knife'
        id = $(m).attr 'marker'
        downloadBtn = $(m).children('input[type="button"]').eq(0)
        downloadBtn.replaceWith "<a href=#{gutenberg.server}/mint/#{id}/answer-key/downloads/answer-key.pdf>answer-key</a>"
    else if url.match(/quiz\/pending_pages/)
      coreUtil.interface.displayJson json.pages, '#pending-pages', 'page'
    else if url.match(/quiz\/pending_scans/)
      here = $('#list-pending')
      here.empty()
      admin.build.list json.students, here, ['within']
      admin.build.list json.scans, here, [], '.student'
      admin.build.list json.responses, here, ['mcq', 'label'], '.scan'
      abacus.initialize()
    else if url.match(/examiner\/suggestions/)
      tab_1 = $('#days-since-receipt')
      tab_2 = $('#typeset-wip')
      tab_3 = $('#typeset-completed')

      # Suggestions for whom no slot has been blocked
      $(m).empty() for m in tab_1.children '.scroll-content'
      scroll.loadJson json.just_in, 'suggestion', tab_1, scroll.having.select
      swissKnife.rebuildSelect $(s), 'num_slots', [0..9] for s in tab_1.find '.swiss-knife'
      tab_1.accordion scroll.options

      # Those that are a work-in-progress
      coreUtil.interface.displayJson json.wips, tab_2, 'suggestion', {radio:false}, true
      # Those whose TeX has been written 
      coreUtil.interface.displayJson json.completed, tab_3, 'suggestion', {radio:false}, true
      # Common preview
      preview.loadJson json, 'locker', true
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
      scroll.loadJson json.topics, 'topic', here, scroll.having.select
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
      coreUtil.interface.displayJson json.teachers, '#teachers-list', 'teacher'
    else if url.match(/school\/sektions/)
      coreUtil.interface.displayJson json.sektions, '#studygroups-radiolist', 'sektion'
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
          scroll.loadJson json.topics, 'topic', $(here), scroll.having.select
        else
          scroll.loadJson json.topics, 'topic', $(here), scroll.having.radio
    else if url.match(/teacher\/specializations/)
      here = $('#teacher-specialization')
      scroll.overlayJson json.subjects, 'subject', here, '.list-item'
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
