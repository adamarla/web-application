
window.fdb = {
  root : null,
  list : null,
  commentBox : null,
  controls: null, 
  nav: null,
  mode: null,
  given: new Array(),
  history: new Array(),

  current : {
    student : null,
    scan : null,
    response : null
  }

  #############################################################
  ## Initialize 
  #############################################################

  initialize : (json) ->
    # Clear old pending list
    here = fdb.pending
    here.empty()

    # Parse the JSON and populate new lists
    fdb.parse json.students, here, ['within']
    fdb.parse json.scans, here, [], '.student'
    fdb.parse json.responses, here, ['mcq', 'label'], '.scan'

    # Set initial values
    fdb.current.student =  fdb.pending.children('.student').eq(0)
    fdb.current.scan = fdb.current.student.children('.scan').eq(0)
    fdb.current.response = fdb.current.scan.children('.gr').eq(0)

    $(fdb.commentBox).typeahead {
      source : fdb.history
    }
    return true

  add : (comment, event) ->
    overlay.add comment, event
    return false unless overlay.xp?
    fdb.given.push { x: overlay.xp, y: overlay.yp, comment: overlay.tex }
    return true

  pop : () ->
    fdb.given.pop()
    overlay.pop()
    return true

  clear : () ->
    fdb.given.length = 0 
    overlay.clear()
    return true

  decompile  : () ->
    ret = "@d@"
    for j in fdb.given 
      for k in ['x', 'y', 'comment' ]
        ret += (if k is 'comment' then "#{encodeURIComponent(j[k])}@d@" else "#{j[k]}@d@")
    return ret

  attach : () ->
    p = $(fdb.root).find('#fdb-preview-area').eq(0)

    preview.create(p)
    overlay.over $(preview.root)
    shadow.over $(overlay.root)

    $(fdb.root).removeClass 'hide'
    fdb.update.ticker()
    return true

  detach : () ->
    preview.create() # within wide-X
    $(fdb.root).addClass 'hide'
    return true


  #############################################################
  ## Parse 
  #############################################################

  parse : (json, within, keys = [], parent = null) ->
    here = fdb.pending
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
      m = $(fdb.root).find('#fdb-ticker').eq(0)
      cq = m.find('#curr-q').eq(0)
      cs = m.find('#curr-s').eq(0)

      cs.text fdb.current.student.attr('name')
      cq.text fdb.current.response.attr('label')

      isGraded = fdb.current.response.hasClass('graded')
      if isGraded then m.addClass('graded') else m.removeClass('graded')

      return true
  }

  #############################################################
  ## Find ( general traversal )
  #############################################################

  find : {
    student : (fwd) -> # if fwd = true, then look for next, else look for previous
      current = fdb.current.student
      return null unless current?

      result = if fwd then current.next() else current.prev()

      if result.length isnt 0
        fdb.current.student = result.eq(0)
        fdb.current.scan = fdb.current.student.children('.scan').eq(0)
        if fdb.current.scan?
          fdb.current.response = fdb.current.scan.children(".gr").eq(0)
          fdb.update.ticker()
          preview.load fdb.current.scan, 'locker'
        else
          fdb.current.response = null
      else
        if fwd then notifier.show('n-last-scan') else notifier.show('n-first-scan')

    scan : (fwd) -> # if fwd = true, then look for next else look for previous 
      fdb.find.student(fwd)
      return fdb.current.scan

    response : (fwd) -> # if fwd = true, then look for next else look for previous
      c = fdb.current.response

      result = if fwd then c.next() else c.prev()
      if result.length isnt 0
        fdb.current.response = result
        fdb.update.ticker()
        fdb.clear() # remove any annotations for a previous question on the same scan
        if result.attr('mcq') is 'false'
          $(fdb.root).removeAttr('mcq')
        else
          $(fdb.root).attr('mcq','true')
        return result

      ###
        No next (prev) question? Well, then move onto the first question in the next(prev)scan
       - which would necessarily be for the next(prev) student because within #list-pending
       are scans for the *same* page for all students
      ###
      
      student = c.parent().parent()
      fdb.find.student(fwd)
      
      if not fdb.current.student?
        if fwd then alert "Grading done .." else alert "Back to first .."
      else
        fdb.update.ticker()

      # student.remove()
      return fdb.current.response
  } # namespace 'find'

  #############################################################
  ## Next and Prev 
  #############################################################

  next : {
    student : () ->
      return fdb.find.student(true)

    scan : () ->
      return fdb.find.scan(true)

    response : () ->
      return fdb.find.response(true)
  } # namespace 'next'

  prev : {
    student : () ->
      return fdb.find.student(false)

    scan : () ->
      return fdb.find.scan(false)

    response : () ->
      return fdb.find.response(false)
  } # namespace 'prev'

}

#############################################################
## Main 
#############################################################

jQuery ->

  unless fdb.root?
    fdb.root = $('#fdb-main')[0]
    fdb.pending = $(fdb.root).find('#pending-scans').eq(0)
    fdb.nav = $(fdb.root).find('#fdb-nav').eq(0) 
    fdb.controls = $(fdb.root).find('#fdb-controls').eq(0)
    fdb.commentBox = $(fdb.root).find('#fdb-typeahead').eq(0)

  ###
    Shared behaviour 
  ###

  fdb.commentBox.focusin (event) ->
    event.stopPropagation()
    rubric.keyboard = false
    return true

  fdb.commentBox.focusout (event) ->
    event.stopPropagation()
    rubric.keyboard = true
    return true

  fdb.nav.on 'click', 'button', (event) ->
    event.stopImmediatePropagation()
    rubric.keyboard = true
    id = $(this).attr 'id'
    switch id 
      when 'btn-prev-ques' then fdb.prev.response()
      when 'btn-next-ques' then fdb.next.response()
      when 'btn-prev-scan' then fdb.prev.scan()
      when 'btn-next-scan' then fdb.next.scan()
    return  true
    
  fdb.controls.on 'click', 'button', (event) ->
    event.stopImmediatePropagation()
    rubric.keyboard = true
    id = $(this).attr 'id'
    fdb.tex = null

    fdbControls = $(this).closest '#fdb-controls'
    $(m).removeClass('active') for m in fdbControls.find('button')
    fdb.mode = null

    switch id
      when 'btn-ok'
        fdb.mode = 'check'
        $(this).addClass 'active'
      when 'btn-cross'
        fdb.mode = 'cross'
        $(this).addClass 'active'
      when 'btn-what'
        fdb.mode = 'question'
        $(this).addClass 'active'
      when 'btn-undo'
        event.stopImmediatePropagation()
        fdb.pop()
      when 'btn-fresh-copy'
        event.stopImmediatePropagation()
        fdb.clear()
        $.get "reset/graded?id=#{fdb.current.response.attr 'marker'}" # will also destroy any associated comments
      when 'btn-rotate'
        event.stopImmediatePropagation()
        scan = "#{fdb.current.scan.attr 'name'}"
        $.get "rotate_scan.json?id=#{scan}"
      when 'btn-write'
        rubric.keyboard = false
        fdb.mode = 'comments'
        fdb.commentBox.focus()
        $(this).addClass 'active'
    return true

  $(fdb.root).on 'click', (event) ->
    event.stopImmediatePropagation()
    return false unless fdb.mode?

    switch fdb.mode
      when 'check'
        fdb.add "$\\surd$", event
      when 'cross'
        fdb.add "$\\times$", event
      when 'question'
        fdb.add "$?$", event
      when 'comments'
        c = fdb.commentBox.val()
        fdb.commentBox.val '' # clear it 
        unique = true
        for m in fdb.history 
          if m is c
            unique = false 
            break
        fdb.history.push c if unique 
        fdb.add c, event 

    return true
    
