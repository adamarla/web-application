
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
              settings.url.match(/questions\/list/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    for oldData in $(this).find '.clear-before-show'
      $(oldData).empty()

    switch matched.pop()
      when 'schools/list'
        displayJson json.schools, '#side-panel', 'school'
        resetRadioUrlsAsPer $('#schools-link')
      when 'courses/list'
        displayJson json.courses, '#side-panel', 'course'
        resetRadioUrlsAsPer $('#courses-link')
      when 'questions/list'
        selections = {0:{1:'introductory', 2:'intermediate', 3:'advanced'}}
        samuraiLineUp '#tbds-summary .samurai-garrison:first', json.questions, 'question',
        ['mcq', 'multi_correct'], ['difficulty'], ['preview'], selections

  ###
    AJAX successes the middle-panel is supposed to respond to.
  ###

  $('#middle-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/yardstick\.json/) or
              settings.url.match(/teachers\/list/) or
              settings.url.match(/school\/sections/) or
              settings.url.match(/topics\/list/) or
              settings.url.match(/course\/coverage/) or
              settings.url.match(/macros\/list/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    for oldData in $(this).find '.clear-before-show'
      $(oldData).empty()

    switch matched.pop()
      when 'teachers/list'
        displayJson json.teachers, '#middle-panel', 'teacher'
        resetRadioUrlsAsPer $('#edit-roster-link')
      when 'school/sections'
        displayJson json.sections, '#middle-panel', 'section'
      when 'yardstick.json'
        uncheckAllCheckBoxesWithin '#edit-yardstick'
        loadFormWithJsonData '#edit-yardstick > form:first', json.yardstick
      when 'topics/list'
        displayJson json.topics, '#middle-panel', 'topic'
      when 'course/coverage'
        displayMacroList json.macros, {radio:true}
        buildSyllabiEditForm json.macros
      when 'macros/list'
        resetMicroTopicList()
        displayMacroList json.macros, {radio:true}

  ###
    AJAX successes the right-panel is supposed to respond to.
  ###

  $('#right-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teachers\/roster/) or
              settings.url.match(/school\/unassigned-students/) or
              settings.url.match(/study_groups\/students/) or
              settings.url.match(/macros\/list/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    for oldData in $(this).find '.clear-before-show'
      $(oldData).empty()

    switch matched.pop()
      when 'teachers/roster'
        displayJson json.sections, '#right-panel', 'section', {checkbox:true}
      when 'school/unassigned-students'
        displayJson json.students, '#right-panel', 'student', {checkbox:true}
      when 'study_groups/students'
        displayJson json.students, '#right-panel', 'student', {checkbox:true}
      when 'macros/list'
        # Customize swiss-knives within microTopics to include just one enabled radio-button
        microTopics = $('#micro-topic-list')
        for macro in microTopics.find 'div[marker]'
          for swissKnife in $(macro).children()
            swissKnifeCustomize $(swissKnife), {radio:true}, true

  ###
    AJAX successes the wide-panel is supposed to respond to.

  $('#wide-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/course\.json/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
  ###
