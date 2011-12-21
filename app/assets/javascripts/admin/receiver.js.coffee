
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
              settings.url.match(/school\/sections/)
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
      when 'yardstick'
        uncheckAllCheckBoxesWithin '#edit-yardstick'
        loadFormWithJsonData '#edit-yardstick > form:first', json.yardstick
  ###
    AJAX successes the right-panel is supposed to respond to.
  ###

  $('#right-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teachers\/roster/) or
              settings.url.match(/school\/unassigned-students/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    for oldData in $(this).find '.clear-before-show'
      $(oldData).empty()

    switch matched.pop()
      when 'teachers/roster'
        displayJson json.sections, '#right-panel', 'section', false
      when 'school/unassigned-students'
        displayJson json.students, '#right-panel', 'student', false

  ###
    AJAX successes the wide-panel is supposed to respond to.
  ###

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
$( function() {

  # Events & Conditions the side-panel is supposed to respond to
  $('#side-panel').ajaxSuccess( function(e,xhr,settings) {
    var json = $.parseJSON(xhr.responseText)

    if (settings.url.match(/schools\/list/) != null) {
      // First, clear any previous data
      $(this).find('.clear-before-show').each( function() { $(this).empty() ; } )
      displaySchoolListInSidePanel( json.schools )
    } else if (settings.url.match(/courses\/list/) != null) {
      // First, clear any previous data
      $(this).find('.clear-before-show').each( function() { $(this).empty() ; } )
      displayCoursesListInSidePanel( json.courses )
      resetRadioUrls('#courses-link')
    }
  })

  # Events & Conditions middle-panel is supposed to respond to
  $('#middle-panel').ajaxSuccess( function(e, xhr, settings) {
    var json = $.parseJSON(xhr.responseText)

    if (settings.url.match(/yardstick\.json\?id=/) != null) { // a GET request
      uncheckAllCheckBoxesWithin('#edit-yardstick')
      loadFormWithJsonData( $('#edit-yardstick > form.formtastic'), json.yardstick)
    } else if (settings.url.match(/teachers\/list/) != null) {
      displayTeachersListInX( json.teachers, '#teachers-list')
    } else if (settings.url.match(/school\/sections\.json\?id=/) != null) {
      displayStudyGroups( json.sections, '#studygroups-radiolist .data:first')
    }
  })

  # Events & Conditions right-panel is supposed to respond to
  $('#right-panel').ajaxSuccess( function(e, xhr, settings) {
    var json = $.parseJSON(xhr.responseText)

    if (settings.url.match(/teachers\/roster/) != null) {
      var url = 'teachers/update_roster.json?id=' + $('#right-panel').attr('marker')

      $(this).find('.clear-before-show').each( function() { $(this).empty() ; } )
      uncheckAllCheckBoxesWithin('#studygroups-list')
      displayStudyGroups( json.sections, '#studygroups-list .data:first', true)
      editFormAction('#studygroups-list', url, 'put')
    } else if (settings.url.match(/school\.json\?id=/) != null) {
      loadFormWithJsonData( $('#edit-school form'), json.school)
    } else if (settings.url.match(/school\/unassigned-students\.json\?id=/) != null) {
      displayJson(json.students, '#student-list .data:first', 'student', false)
    } else if (settings.url.match(/study_groups\/students\.json\?id=/) != null) {
      displayJson(json.students, '#student-list .data:first', 'student', false)
    }
  })

  # Events & Conditions #wide-panel is supposed to respond to
  $('#wide-panel').ajaxSuccess( function(e, xhr, settings) {
    var json = $.parseJSON(xhr.responseText)

    if (settings.url.match(/course\.json\?id=/) != null) { // a GET request
      arrangeDumpIntoColumns('#edit-syllabi-megaform > form:first')
      uncheckAllCheckBoxesWithin('#edit-syllabi-megaform')
      disableAllSelectsWithin('#edit-syllabi-megaform')
      loadSyllabiEditFormWith(json.course.syllabi)
    }
  })

})
