
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
              settings.url.match(/courses\/list/)
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

  ###
    AJAX successes the middle-panel is supposed to respond to.
  ###

  $('#middle-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/yardstick\.json/) or
              settings.url.match(/teachers\/list/) or
              settings.url.match(/school\/sections/) or
              settings.url.match(/topics\/list/) or
              settings.url.match(/course\/coverage/)
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
        ### 
          We will need to set URLs of the form : 
            macro_topic/micros_in_course.json?course=<sth>&id=<to be filled>
          To do this, we need the currently selected course's ID. Where is that? 
          As the 'marker' attribute on the side-panel
        course = $('#side-panel').attr 'marker'
        url = "macro_topic/micros_in_course.json?course=#{course}&id="
        resetRadioUrlsIn '#middle-panel', url
        ###

  ###
    AJAX successes the right-panel is supposed to respond to.
  ###

  $('#right-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teachers\/roster/) or
              settings.url.match(/school\/unassigned-students/) or
              settings.url.match(/study_groups\/students/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    for oldData in $(this).find '.clear-before-show'
      $(oldData).empty()

    switch matched.pop()
      when 'teachers/roster'
        displayJson json.sections, '#right-panel', 'section', false, true
      when 'school/unassigned-students'
        displayJson json.students, '#right-panel', 'student', false, true
      when 'study_groups/students'
        displayJson json.students, '#right-panel', 'student', false, true

  ###
    AJAX successes the wide-panel is supposed to respond to.

  $('#wide-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/course\.json/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'course.json'
        arrangeDumpIntoColumns '#edit-syllabi-megaform form:first'
        uncheckAllCheckBoxesWithin('#edit-syllabi-megaform')
        disableAllSelectsWithin('#edit-syllabi-megaform')
        loadSyllabiEditFormWith(json.course.syllabi)
  ###
