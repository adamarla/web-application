

window.postUpload = () -> # written as onload in modal/teachers/_suggestion.html.haml
  uploadModal = $('#m-suggestion-upload')
  uploadModal.find("input[type='file']").eq(0).val null
  uploadModal.modal 'hide'
  return true

jQuery ->
  window.variables = {
    testpaper : {
      span : 0, # the exact running total 
      spread : 0, # span aprroximated to nearest greatest integer
      blank : 0, # either 0 or 1, depending on whether spread is odd or even
      reset : () ->
        variables.testpaper.span = variables.testpaper.spread = variables.testpaper.blank = 0
        tickers = $('#testpaper-span').children()
        tickers.eq(1).text "0"
        tickers.eq(2).text "0"
        return true
    }
  }

  # teacher = $('#control-panel').attr 'marker'
  # $.get 'quizzes/list.json'

  ###
  $('#main-links a').click ->
    teacher = $('#control-panel').attr 'marker'
    id = $(this).attr 'id'
    switch id
      when 'quizzes-link'
        $.get 'quizzes/list.json'
        $.get "teacher/sektions.json?id=#{teacher}"
      when 'report-cards-link'
        $.get "teacher/testpapers.json?id=#{teacher}"
      when 'sektions-link'
        $.get "teacher/sektions.json?id=#{teacher}"
        $.get "teacher/students.json?id=#{teacher}&exclusive=no"
    return true
  ###

  # Assigning a Quiz to students selected in #student-list
  $('#student-list > form:first').submit ->
    tabs = flipchart.tabsList $(this)

    quizTab = tabs.children('li').eq(0)
    quiz = quizTab.attr 'marker'
    return if not quiz?
    # alert quiz

    coreUtil.forms.modifyAction $(this), "quiz/assign.json?id=#{quiz}", 'put'
    flipchart.next '#quizzes-summary'
    return true

  ###
    On load, auto-click the first main-link > a that has attribute default='true'
  ###
  $('#main-links a[default="true"]:first').click()

  ###
    If an accordion is rendered within a flipchart page, then opening the 
    accordion by clicking on an accordion-header should enable the next tab. 
    This is being done first within #past-quizzes when assigning a quiz. Not 
    sure if this behaviour is desired everytime and should hence be in core 
  ###
  $('#past-quizzes-list').on 'click', '.scroll-heading', (event) ->
    event.stopPropagation()

    chart = $(this).closest '.flipchart'
    tab = flipchart.containingTab $(this)

    id = $(this).attr 'marker'
    chart.tabs 'enable', 1
    tab.attr 'marker', id

    $.get "quiz/preview.json?id=#{id}"

    # Get the list of testpapers only once. Its unlikely to have changed 
    # in the lifetime of a user-session 
    content = $(this).next()
    return true if content.children().length isnt 0 # there will always be the one download button
    btn = $("<a class='btn' href=#{gutenberg.server}/atm/#{id}/answer-key/downloads/answer-key.pdf>download pdf</a>")
    btn.appendTo content
    btn.button()

    $.get "quiz/testpapers.json?id=#{id}"
    return true

  ###
    (Process all minor-links > a here)

    1. clicking the new-quiz-link should should load the list of courses 
    taught by the logged-in teacher
  ###
  $('#minor-links').on 'click', 'a', (event) ->
    link = $(this).attr 'id'
    return if not link?

    matched = true
    teacher = $('#control-panel').attr 'marker'
    switch link
      when 'new-quiz-link'
        $.get "teacher/courses.json?id=#{teacher}"
      when 'deep-dive-link'
        $.get "teacher/sektions.json?id=#{teacher}"
      when 'my-suggestions-link'
        $.get "teacher/suggested_questions?id=#{teacher}"
      when 'disputes-link'
        $.get "disputed?id=#{teacher}"
      else
        matched = false

    #event.stopPropagation() if matched is true
    return true

  ###
    When a radio-button within a flipchart is clicked 
  ###
  $('.flipchart').on 'click', 'input[type="radio"]', ->
    chart = $(this).closest '.ui-tabs-panel'
    marker = $(this).attr 'marker'
    id = chart.attr 'id'

    switch id
      when 'courses-taught'
        $.get "course/verticals.json?id=#{marker}"
      when 'sektion-list'
        $.get "sektion/students.json?id=#{marker}&context=#{marker}"
      when 'testpaper'
        wide = $('#wide-panel')
        first = wide.children().eq(0).attr 'id'
        wide.empty() if first isnt 'flot-chart'
        $('#flot-chart').empty().detach().appendTo wide
        $.get "testpaper/summary.json?id=#{marker}"
      when 'student'
        tab = flipchart.containingTab $(this)
        $('#flot-chart').detach().appendTo('#toolbox')
        previous = tab.prev 'li'
        testpaper = previous.attr 'marker'
        $.get "student/responses.json?id=#{marker}&testpaper=#{testpaper}"
      when 'deep-dive-section'
        tab = flipchart.containingTab $(this)
        marker = tab.attr 'marker'
        teacher = $('#control-panel').attr 'marker'
        $.get "teacher/topics_this_section.json?id=#{teacher}&section_id=#{marker}"
      when 'deep-dive-topic'
        tab = flipchart.containingTab $(this)
        marker = tab.attr 'marker'
        previous = tab.prev 'li'
        section = previous.attr 'marker'
        $.get "sektion/proficiency.json?id=#{section}&topic=#{marker}"


    return true

  ###
    Toggle 'Questions <-> My Suggestions' for a given selection
    of questions
  ###
  $('#tab-qzb-3').on 'click', (event) ->
    event.stopPropagation()
    topicSelected =  $('[id^="qzb-pick-"].active')
    unless $('#show-selected').is(':checked')
      topicSelected.children('[page]').removeClass 'hide'
      candidates = $('#qzb-questions').find('.btn.btn-mini').parents('.single-line.leaf')
    else
      candidates = $('#qzb-questions').find('.btn.btn-mini.active').parents('.single-line.leaf')
    candidates.not('.fav').hide()
    $('#tab-qzb-2').parent().removeClass 'active'
    $('#tab-qzb-3').parent().addClass 'active'
    return true

  $('#tab-qzb-2').on 'click', (event) ->
    event.stopPropagation()
    topicSelected =  $('[id^="qzb-pick-"].active')
    if $('#show-selected').is(':checked')
      $('#qzb-questions').find('.btn.btn-mini.active').parent().show()
    else
      topicSelected.children('[page]').removeClass 'show'
      topicSelected.children('[page]').addClass 'hide'
      if $('#left-paginator > ul > li.active').not('.disabled').length is 0
        pageSelected = 1
      else
        pageSelected = $('#left-paginator > ul > li.active > a')[0].text
      topicSelected.children('[page="'+pageSelected+'"]').removeClass 'hide'
      $('#qzb-questions').find('.single-line.leaf').show()
    $('#tab-qzb-3').parent().removeClass 'active'
    $('#tab-qzb-2').parent().addClass 'active'
    return true

  ###
    Step 2 of the 'quiz-building' process: topic selection
  ###
  $('#topic-selection-list').on 'click', '.scroll-heading', (event) ->
    event.stopPropagation()
    content = $(this).next()
    return if content.children().length isnt 0
    # if list already populated then do *not* repopulate it. 
    # It is highly unlikely that the list of topics will change during the session

    id = $(this).attr 'marker'
    course = flipchart.containingTab($(this)).prev().attr 'marker'
    $.get "course/topics_in.json?id=#{course}&vertical=#{id}"
    return true
   

  ###
    Step 3 of the 'quiz-building' process: topic selection 
  ###
  $('#topic-selection-list').submit ->
    form = $(this).children 'form:first'
    nChecked = coreUtil.forms.numChecked form
    if nChecked is 0
      coreUtil.interface.modalMsg "Pick at least one topic",
              ["These are topics you want to cover in the quiz. Select one or more from the list below"]
      return false

    courseId = $('#build-quiz').attr 'marker'
    teacherId = $('#control-panel').attr 'marker'
    form.attr 'action', "course/questions.json?id=#{courseId}&teacher_id=#{teacherId}"
    return true

  ###
    Before submitting questions toggle for Selected Questions list
  ###
  $('#form-qzb :checkbox').click ->
    $this = $(this)
    topicSelected =  $('[id^="qzb-pick-"].active')
    if $this.is(':checked')
      unless $('#tab-qzb-3').parent().hasClass('active')
        topicSelected.children('[page]').removeClass 'hide'
        candidates = $('#qzb-questions').find('.single-line.leaf')
      else  
        candidates = $('#qzb-questions').find('.single-line.leaf.fav')
      candidates.children('.btn.btn-mini').not('.active').parent().hide()
    else 
      if $('#tab-qzb-3').parent().hasClass('active')
        $('#qzb-questions').find('.single-line.leaf.fav').show()
      else
        topicSelected.children('[page]').addClass 'hide'
        if $('#left-paginator > ul > li.active').not('.disabled').length is 0
          pageSelected = 1
        else
          pageSelected = $('#left-paginator > ul > li.active > a')[0].text
        topicSelected.children('[page="'+pageSelected+'"]').removeClass 'hide'
        $('#qzb-questions').find('.single-line.leaf').show()

  ###
    Step 4 of the 'quiz-building' process: Submitting the question selection 
  ###
  $('#question-options').submit ->
    form = $(this).children 'form:first'
    nChecked = coreUtil.forms.numChecked form
    if nChecked is 0
      coreUtil.interface.modalMsg "Select questions for the quiz",
              ["A question is selected when the checkbox alongside it is checked. Pick one or more questions before proceeding",
               "And don't forget to give the quiz a name"]
      return false

    courseId = $('#build-quiz').attr 'marker'
    teacherId = $('#control-panel').attr 'marker'
    form.attr 'action', "teacher/build_quiz.json?course_id=#{courseId}&id=#{teacherId}"
    flipchart.next '#build-quiz'
    return true

  $('#question-options, #typeset-for-me').on 'click', '.swiss-knife', (event) ->
    event.stopPropagation()
    for m in $(this).siblings()
      $(m).removeClass 'selected'
    $(this).addClass 'selected'

    uid = $(this).children('.label').eq(0).text()
    stop = preview.isAt uid
    current = preview.currIndex()
    preview.jump current, stop

    trigger = $(event.target)

    if trigger.is 'input[type="button"]'
      id = $(this).attr 'marker'
      liked = trigger.attr('liked')
      if not liked? or liked is "false"
        $.get "teacher/like_q.json?id=#{id}"
        trigger.attr 'liked', true
        trigger.attr 'title', 'remove from favourites list'
      else
        $.get "teacher/unlike_q.json?id=#{id}"
        trigger.attr 'liked', false
        trigger.attr 'title', 'add to favourites list'
    else if trigger.is 'input[type="checkbox"]'
      span = $(this).attr 'span'
      if trigger.prop 'checked'
        variables.testpaper.span += parseFloat(span)
      else
        variables.testpaper.span -= parseFloat(span)
      variables.testpaper.spread = Math.ceil( variables.testpaper.span )
      variables.testpaper.blank = if variables.testpaper.spread % 2 is 0 then 0 else 1
      tickers = $('#testpaper-span').children()
      tickers.eq(2).text "#{variables.testpaper.spread}"
      tickers.eq(1).text "+ #{variables.testpaper.blank} blank"

    return true

  $('#all-my-sektions').on 'click', 'input[type="radio"]', ->
    id = $(this).attr 'marker'
    $.get "sektion/students.json?id=#{id}"
    return true

  $('#update-sektion > form:first').submit ->
    sektion_id = $('#side-panel').attr 'marker'
    return false if not sektion_id?

    coreUtil.forms.modifyAction $(this), "sektion.json?id=#{sektion_id}", 'put'
    return true

  ###
    DISPUTE RESOLUTION
  ###
  $('#disputes').on 'click', '.swiss-knife', (event) ->
    event.stopPropagation()
    disputed = $('#disputes').find('.swiss-knife')
    # n = disputed.index $(this)
    n = preview.isAt $(this).attr 'marker'
    curr = preview.currIndex()
    preview.jump curr, n
    $(m).removeClass 'selected' for m in $(this).siblings()
    $(this).addClass 'selected'
    return true

  ###
    SUGGESTION UPLOAD
  ###
  
  $('#m-suggestion-upload').on 'click', 'button', (event) ->
    x = $(this).siblings()
    file = x.filter("[type='file']")[0]
    warning = x.filter(".subtext")[0]

    if $(file).val().length > 0 # => sth. selected
      $(warning).addClass 'hide' # => next = plz. select file first msg 
    else
      $(warning).removeClass 'hide'
      event.stopImmediatePropagation()
      return false
    return true

