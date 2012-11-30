
###
  An abacus is a special instance of an accordion - realized using scroll.js - 
  that is used only during grading 

  In particular, it allows an examiner - and in the future, perhaps even a teacher - 
  to "record" - in a step-wise manner - his/her assessment of what the student 
  has achieved on 3 fronts - insight, formulation & calculation

  Abacus ensures that an examiner always starts w/ insight and only then moves 
  onto formulation & calculation

  It also has intelligence so that if there are no further selectable options 
  based on the current selection, then it automatically submits the underlying <form>
###

window.abacus = {
  obj : null,
  current : {
    student : null,
    scan : null,
    response : null
  },

  memory : {
    i : null, # insight
    f : null, # formulation
    c : null, # calculation
    m : null, # mcq

    reset : () ->
      abacus.memory.i = null
      abacus.memory.f = null
      abacus.memory.c = null
      abacus.memory.m = null
      return true
  },

  panel : {
    current : 0,
    next : null,
    containing : (radio) ->
      # Returns the index of the .scroll-content containing the passed 
      # radio button relative to the other .scroll-contents 
      panel = radio.closest '.scroll-content'
      index = abacus.obj.children('.scroll-content').index(panel)
      return index

    autoClickable : (n) ->
      return false if n is 0
      panel = abacus.obj.children('.scroll-content').eq(n)
      clickable = panel.find("input[type='radio']").not("[disabled]")
      return clickable.length is 1
      
    autoClick : (n) ->
      panel = abacus.obj.children('.scroll-content').eq(n)
      clickable = panel.find("input[type='radio']").not("[disabled]")
      radio = clickable.eq(0)
      radio.trigger 'click'
      return true
  }

  decompile : (n) ->
    alert "[#{n}] #{abacus.current.student.attr 'name'} --> #{abacus.current.scan.attr 'name'} --> #{abacus.current.response.attr 'marker'}"

  initialize : (here = '#abacus') ->
    abacus.obj = if typeof here is 'string' then $(here) else here
    abacus.obj.accordion scroll.options
    abacus.obj.accordion 'option', 'collapsible', false
    abacus.obj.accordion 'option', 'active', 0
    abacus.obj.accordion 'activate', 0

    pending = $('#list-pending')
    abacus.current.student =  pending.children('.student').eq(0)
    abacus.current.scan = abacus.current.student.children('.scan').eq(0)
    abacus.current.response = abacus.current.scan.children('.gr').eq(0)
    abacus.update.ticker()

    canvas.load abacus.current.scan
    return true

  load : (n) ->
    mem = $('#flash-memory')
    panel = abacus.obj.children('.scroll-content').eq(n)

    switch n
      when 0
        abacus.memory.reset()
      when 1
        candidates = mem.children("div[i=#{abacus.memory.i}]")
        key = 'f'
      when 2
        candidates = mem.children("div[i=#{abacus.memory.i}][f=#{abacus.memory.f}]")
        key = 'c'

    return true if n is 0 # nothing more needs to be done if on insights

    for m in candidates
      target = $(m).attr key
      for k in panel.children(".level[marker=#{target}]")
        $(k).removeClass 'disabled'
        $(b).prop 'disabled', false for b in $(k).children("input[type='radio']")
    return true

  reset : (n) ->
    return false if n > 2
    panel = abacus.obj.find('.scroll-content').eq(n)

    for m in panel.find 'input[type="radio"]'
      $(m).prop 'checked', false
      $(m).prop 'disabled', (n isnt 0) # radios in insight panel are always enabled

    $(k).addClass 'disabled' for k in panel.children('.level') unless n is 0
    return true

   find : {
    student : (fwd) -> # if fwd = true, then look for next, else look for previous
      current = abacus.current.student
      result = if fwd then current.next() else current.prev()

      if result.length isnt 0
        abacus.current.student = result.eq(0)
        abacus.current.scan = abacus.current.student.children('.scan').eq(0)
        if abacus.current.scan?
          abacus.current.response = abacus.current.scan.children(".gr").eq(0)
        else
          abacus.current.response = null

    scan : (fwd) -> # if fwd = true, then look for next else look for previous 
      result = abacus.find.student(fwd)
      if result? then return result.children('.scan').eq(0) else return null
      # return abacus.next.student().children('.scan').eq(0)

    response : (fwd) -> # if fwd = true, then look for next else look for previous
      c = abacus.current.response

      result = if fwd then c.next() else c.prev()
      if result.length isnt 0
        abacus.current.response = result
        canvas.clear() # remove any annotations for a previous question on the same scan
        if result.attr('mcq') is 'false'
          abacus.obj.removeAttr('mcq')
        else
          abacus.obj.attr('mcq','true')
        return result

      ###
        No next (prev) question? Well, then move onto the first question in the next(prev)scan
       - which would necessarily be for the next(prev) student because within #list-pending
       are scans for the *same* page for all students
      ###
      
      student = c.parent().parent()
      abacus.find.student(fwd)
      
      if not abacus.current.student?
        if fwd then alert "Grading done .." else alert "Back to first .."

      # student.remove()
      return abacus.current.response
  } # namespace 'find'

  next : {
    student : () ->
      return abacus.find.student(true)

    scan : () ->
      return abacus.find.scan(true)

    response : () ->
      return abacus.find.response(true)
  } # namespace 'next'

  prev : {
    student : () ->
      return abacus.find.student(false)

    scan : () ->
      return abacus.find.scan(false)

    response : () ->
      return abacus.find.response(false)
  } # namespace 'prev'

  update : {
    ticker : () ->
      $('#current-student').text abacus.current.student.attr 'name'

      alreadyGraded = abacus.current.response.hasClass 'graded'
      $('#current-question').text abacus.current.response.attr 'label'
      $('#currently-annotating').text abacus.current.response.attr 'label'

      if alreadyGraded
        $('#current-question').addClass 'graded'
        $('#currently-annotating').addClass 'graded'
      else
        $('#current-question').removeClass 'graded'
        $('#currently-annotating').removeClass 'graded'
      return true
  }

  tagAsGraded : () ->
    question = abacus.current.response
    question.addClass 'graded'
    allDone = if question.siblings().length isnt 0 then false else true
    question.parent().parent().addClass 'graded' if allDone
    return allDone

} # namespace abacus 

jQuery ->
  
  ###
    Behaviour
  ###

  $('#abacus .scroll-content').on 'click', 'input[type="radio"]', (event) ->
    event.stopPropagation()
    abacus.panel.current = abacus.panel.containing $(this)
    abacus.panel.next = (abacus.panel.current + 1) % 3

    $(m).prop 'checked', false for m in $(this).parent().siblings('.level').children('input[type="radio"]')
    parent = $(this).parent()

    switch abacus.panel.current
      when 0
        abacus.memory.i = parent.attr 'marker'
      when 1
        abacus.memory.f = parent.attr 'marker'
      when 2
        abacus.memory.c = parent.attr 'marker'
        url = "i=#{abacus.memory.i}&f=#{abacus.memory.f}&c=#{abacus.memory.c}&g=#{abacus.current.response.attr 'marker'}"
        form = abacus.obj.closest('form')
        form.attr 'action', "/calibrate?#{url}&clicks=#{canvas.decompile()}"
        form.trigger 'submit'
        abacus.tagAsGraded()
        abacus.next.response() # Move to the next response
        abacus.update.ticker()

    abacus.reset abacus.panel.next
    abacus.load abacus.panel.next
    if abacus.panel.autoClickable abacus.panel.next
      abacus.panel.autoClick abacus.panel.next
    else
      abacus.obj.accordion 'activate', abacus.panel.next
    return true

