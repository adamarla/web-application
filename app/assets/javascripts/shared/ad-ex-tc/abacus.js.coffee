
window.abacus = {
  root : null,
  list : null,
  commentBox : null,
  controls: null, 
  nav: null,

  current : {
    student : null,
    scan : null,
    response : null
  }

  #############################################################
  ## Initialize 
  #############################################################

  initialize : (json) ->

    # Prep
    here = abacus.pending
    here.empty()

    # Populate 
    abacus.parse json.students, here, ['within']
    abacus.parse json.scans, here, [], '.student'
    abacus.parse json.responses, here, ['mcq', 'label'], '.scan'

    # Initialize 
    abacus.current.student =  abacus.pending.children('.student').eq(0)
    abacus.current.scan = abacus.current.student.children('.scan').eq(0)
    abacus.current.response = abacus.current.scan.children('.gr').eq(0)

    # Activate
    abacus.update.ticker()
    if canvas.object?
      if canvas.object.attr('id') isnt 'grading-canvas'
        canvas.initialize '#grading-canvas'
    else
      canvas.initialize '#grading-canvas'
    canvas.load abacus.current.scan

    return true

  #############################################################
  ## Parse 
  #############################################################

  parse : (json, within, keys = [], parent = null) ->
    here = abacus.pending
    # 1. Two keys - marker & class have to be present
    # 2. Another 2 keys - name & parent are highly likely to be present
    # 3. Any other key is case-specific
    # We therefore append (1) and (2) anyways so that the developer only need specify (3)

    keys = keys.concat ['marker', 'class', 'name', 'parent']

    within = if typeof within is 'string' then $(within) else within
    for r in json
      if r instanceof Array then r = r[0]
      e = "<div" # start a self-closing div, that is <div ... />
      for k in keys
        e = "#{e} #{k}=#{r[k]}" if r[k]?
      e = "#{e}/>" # close the div

      if r.parent? and parent?
        target = within.find(parent).filter("[marker=#{r.parent}]").eq(0)
        $(e).appendTo target if target?
      else
        $(e).appendTo within
    return true

  #############################################################
  ## Update Ticker
  #############################################################

  update : {
    ticker : () ->
      m = abacus.root.find('#grd-ticker').eq(0)
      cq = m.find('#curr-q').eq(0)
      cs = m.find('#curr-s').eq(0)

      cs.text abacus.current.student.attr('name')
      cq.text abacus.current.response.attr('label')

      isGraded = abacus.current.response.hasClass('graded')
      if isGraded then m.addClass('graded') else m.removeClass('graded')

      return true
  }

  #############################################################
  ## Find ( general traversal )
  #############################################################

  find : {
    student : (fwd) -> # if fwd = true, then look for next, else look for previous
      current = abacus.current.student
      return null unless current?

      result = if fwd then current.next() else current.prev()

      if result.length isnt 0
        abacus.current.student = result.eq(0)
        abacus.current.scan = abacus.current.student.children('.scan').eq(0)
        if abacus.current.scan?
          abacus.current.response = abacus.current.scan.children(".gr").eq(0)
          abacus.update.ticker()
          canvas.load abacus.current.scan
        else
          abacus.current.response = null
      else
        if fwd then notifier.show('n-last-scan') else notifier.show('n-first-scan')

    scan : (fwd) -> # if fwd = true, then look for next else look for previous 
      abacus.find.student(fwd)
      return abacus.current.scan

    response : (fwd) -> # if fwd = true, then look for next else look for previous
      c = abacus.current.response

      result = if fwd then c.next() else c.prev()
      if result.length isnt 0
        abacus.current.response = result
        abacus.update.ticker()
        canvas.clear() # remove any annotations for a previous question on the same scan
        if result.attr('mcq') is 'false'
          abacus.root.removeAttr('mcq')
        else
          abacus.root.attr('mcq','true')
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
      else
        abacus.update.ticker()

      # student.remove()
      return abacus.current.response
  } # namespace 'find'

  #############################################################
  ## Next and Prev 
  #############################################################

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

}

#############################################################
## Main 
#############################################################

jQuery ->

  unless abacus.root?
    abacus.root = $('#wide-grd-canvas')
    abacus.pending = abacus.root.find('#pending-scans').eq(0)
    abacus.nav = abacus.root.find('#grd-nav').eq(0) 
    abacus.controls = abacus.root.find('#grd-controls').eq(0)
    abacus.commentBox = abacus.root.find('#grd-typeahead').eq(0)

  ###
    Shared behaviour 
  ###

  abacus.commentBox.focusin (event) ->
    event.stopPropagation()
    grtb.keyboard = false
    return true

  abacus.nav.on 'click', 'button', (event) ->
    event.stopImmediatePropagation()
    grtb.keyboard = true
    id = $(this).attr 'id'
    switch id 
      when 'btn-prev-ques' then abacus.prev.response()
      when 'btn-next-ques' then abacus.next.response()
      when 'btn-prev-scan' then abacus.prev.scan()
      when 'btn-next-scan' then abacus.next.scan()
    return  true
    
  abacus.controls.on 'click', 'button', (event) ->
    grtb.keyboard = true
    id = $(this).attr 'id'

    switch id
      when 'btn-ok'
        canvas.mode = 'check'
      when 'btn-cross'
        canvas.mode = 'cross'
      when 'btn-what'
        canvas.mode = 'question'
      when 'btn-undo'
        event.stopImmediatePropagation()
        canvas.undo()
      when 'btn-fresh-copy'
        event.stopImmediatePropagation()
        scan = "#{abacus.current.scan.attr 'name'}"
        $.get "restore_scan.json?id=#{scan}"
      when 'btn-rotate'
        event.stopImmediatePropagation()
        scan = "#{abacus.current.scan.attr 'name'}"
        $.get "rotate_scan.json?id=#{scan}"
      when 'btn-write'
        grtb.keyboard = false
        canvas.mode = 'comments'
        abacus.commentBox.focus()
    return true
