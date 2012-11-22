
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
  last : {
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
    alert "[#{n}] #{abacus.last.student.attr 'name'} --> #{abacus.last.scan.attr 'name'} --> #{abacus.last.response.attr 'marker'}"

  initialize : (here = '#abacus') ->
    abacus.obj = if typeof here is 'string' then $(here) else here
    abacus.obj.accordion scroll.options
    abacus.obj.accordion 'option', 'collapsible', false
    abacus.obj.accordion 'option', 'active', 0
    abacus.obj.accordion 'activate', 0

    pending = $('#list-pending')
    abacus.last.student =  pending.children('.student').eq(0)
    abacus.last.scan = abacus.last.student.children('.scan').eq(0)
    abacus.last.response = abacus.last.scan.children('.gr').eq(0)
    abacus.update.ticker()

    canvas.load abacus.last.scan
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

  next : {
    student : () ->
      next_student = abacus.last.student.next()
      if next_student.length isnt 0 then return next_student.eq(0) else return null

    scan : () ->
      next_student = abacus.next.student()
      if next_student? then return next_student.children('.scan').eq(0) else return null
      # return abacus.next.student().children('.scan').eq(0)

    response : () ->
      c = abacus.last.response
      next = c.next() # next question on the same page of the same student
      if next.length isnt 0
        abacus.last.response = next
        canvas.clear() # remove any annotations for a previous question on the same scan
        if next.attr('mcq') is 'false'
          abacus.obj.removeAttr('mcq')
        else
          abacus.obj.attr('mcq','true')
        return next

      ###
        No next question? Well, then move onto the first question in the next scan
       - which would necessarily be for the next student because within #list-pending
       are scans for the *same* page for all students

       Remember to delete this response, its parent scan and then the parent student
       An empty #list-pending => grading done
      ###
      
      student = c.parent().parent()
      abacus.last.student = abacus.next.student()

      if abacus.last.student?
        abacus.last.scan = abacus.last.student.children('.scan').eq(0)
        abacus.last.response = if abacus.last.scan? then abacus.last.scan.children('.gr').eq(0) else null
        canvas.load abacus.last.scan
      else # grading done
        alert "Grading done ..."

      student.remove()
      return abacus.last.response
  } # namespace 'next'

  update : {
    ticker : () ->
      $('#current-student').text abacus.last.student.attr 'name'
      $('#current-question').text abacus.last.response.attr 'label'
      $('#currently-annotating').text abacus.last.response.attr 'label'
      return true
  }

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
        url = "i=#{abacus.memory.i}&f=#{abacus.memory.f}&c=#{abacus.memory.c}&g=#{abacus.last.response.attr 'marker'}"
        form = abacus.obj.closest('form')
        form.attr 'action', "/calibrate?#{url}&clicks=#{canvas.decompile()}"
        form.trigger 'submit'
        abacus.next.response() # Move to the next response
        abacus.update.ticker()

    abacus.reset abacus.panel.next
    abacus.load abacus.panel.next
    if abacus.panel.autoClickable abacus.panel.next
      abacus.panel.autoClick abacus.panel.next
    else
      abacus.obj.accordion 'activate', abacus.panel.next
    return true

