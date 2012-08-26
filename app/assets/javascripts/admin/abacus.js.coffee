
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
  }

  decompile : (n) ->
    alert "[#{n}] #{abacus.last.student.attr 'name'} --> #{abacus.last.scan.attr 'name'} --> #{abacus.last.response.attr 'marker'}"

  initialize : (here = '#abacus') ->
    abacus.obj = if typeof here is 'string' then $(here) else here
    abacus.obj.accordion scroll.options
    abacus.obj.accordion 'activate', 0

    pending = $('#list-pending')
    abacus.last.student =  pending.children('.student').eq(0)
    abacus.last.scan = abacus.last.student.children('.scan').eq(0)
    abacus.last.response = abacus.last.scan.children('.gr').eq(0)
    abacus.update.ticker()

    return true

  url : (radio) ->
    # Build <form> href argument by looking at current & prior selections
    currId = abacus.obj.accordion 'option','active'
    url = null
    id = radio.parent().attr 'marker'

    switch currId
      when 0
        url = id
      when 1
        url = abacus.obj.children('.scroll-content').eq(0).attr 'choice'
        url = "#{url}?f=#{id}"
      when 2
        prior = abacus.obj.children('.scroll-content')
        url = "?i=#{prior.eq(0).attr 'choice'}" # ?i=67
        url = "#{url}&f=#{prior.eq(1).attr 'choice'}" # ?i=67&f=74
        url = "#{url}&c=#{id}" # ?i=67&f=74&c=89

        # Dont forget to embed the graded-response id too
        url = "#{url}&g=#{abacus.last.response.attr 'marker'}" # ?i=67&f=74&c=89&g=1275

    return url

  next : {

    yardstick : () ->
      # Open the next scroll-content OR submit if last scroll-content
      currId = abacus.obj.accordion 'option', 'active'
      abacus.obj.accordion('activate', currId + 1) if currId < 2
      return true

    student : () ->
      return abacus.last.student.next().eq(0)

    scan : () ->
      return abacus.next.student().children('.scan').eq(0)

    response : () ->
      c = abacus.last.response
      next = c.next() # next question on the same page of the same student
      if next.length isnt 0
        # abacus.decompile(1.9)
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

  }

  update : {
    ticker : () ->
      $('#current-student').text abacus.last.student.attr 'name'
      $('#current-question').text abacus.last.response.attr 'label'
      return true
  }

  current: () ->
    currId = abacus.obj.accordion 'option', 'active'
    return abacus.obj.children('.scroll-content').eq(currId)

  autoClick : (current) ->
    clickable = current.find("input[type='radio']").not("[disabled]")
    if clickable.length == 1
      radio = clickable.eq(0)
      radio.click()
    return true
}

jQuery ->
  
  ###
    Behaviour
  ###

  $('#grade-abacus > form').submit ->
    # alert 'inside submit'
    abacus.next.response() # Move to the next response
    abacus.update.ticker()
    abacus.obj.accordion 'activate', 0
    return true

  $('#abacus .scroll-content').on 'click', 'input[type="radio"]', (event) ->
    event.stopPropagation()

    siblings = $(this).parent().siblings('.level').children('input[type="radio"]')
    $(m).prop('checked', false) for m in siblings

    abacus.current().attr 'choice', $(this).parent().attr('marker')
    # GET request for next set of yardsticks to show OR form submission 
    url = abacus.url $(this)

    currId = abacus.obj.accordion 'option', 'active'
    switch currId
      when 0,1 then $.get "yardstick/logical_next/#{url}"
      when 2
        form = $(this).closest 'form'
        form.attr 'action', "/assign/grade#{url}&clicks=#{canvas.decompile()}"
        form.submit()

    return true

  ###
    Receiver
  ###

  $('#abacus').ajaxSuccess (e,xhr,settings) ->
    url = settings.url

    return true unless url.match(/yardstick\/logical_next/)
    e.stopPropagation()

    json = $.parseJSON xhr.responseText
    abacus.next.yardstick()
    currId = abacus.obj.accordion 'option', 'active'
    key = null

    switch currId
      when 1 then key = 'formulation'
      when 2 then key = 'calculation'

    current = abacus.current()
    scroll.overlayJson json[key], 'candidates', current, '.level', "disable" if key?
    abacus.autoClick current # wouldn't do anything if current has > 1 clickable options
    return true
