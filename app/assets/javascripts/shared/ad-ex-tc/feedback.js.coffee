
window.fdb = {
  root : null,
  list : null,
  controls: null, 
  nav: null,
  mode: null,
  given: new Array(),
  history: new Array(),
  ticker : null,

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

    for scan in json.pending 
      e = "<div" # start a self-closing <div>
      e += " #{j}=#{scan[j]}" for j in ['marker', 'tag']
      e += "/>"

      m = $(e).appendTo here
      for rsp in scan.gr 
        f = "<div"
        f += " #{k}=#{rsp[k]}" for k in ['marker', 'tag', 'shadow']
        f += "/>"
        $(f).appendTo m 

    # Load historical comments 
    fdb.history.length = 0
    fdb.update.history json

    # Set values for fdb.current.*
    c = here.children()[0]
    fdb.current.student = c 
    fdb.current.response = $(c).children()[0]
    fdb.current.scan = $(c).attr 'marker'
    fdb.update.view()

    # Customize grading panel if in sandbox mode
    buttons = fdb.controls.find 'button'
    if json.sandbox 
      for btn in ['btn-fresh-copy', 'btn-rotate']
        b = buttons.filter("[id=#{btn}]").eq(0)
        b.addClass 'disabled'
      notifier.show 'n-sandbox-tips'
    else
      $(b).removeClass('disabled') for b in buttons
      
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

    unless fdb.ticker?
      fdb.ticker = window.setInterval () -> fdb.ping(), 
      300000 # 5 min 
    return true

  detach : () ->
    preview.create() # within wide-X
    $(fdb.root).addClass 'hide'

    if fdb.ticker?
      window.clearInterval fdb.ticker  
      fdb.ticker = null
    fdb.clear()
    return true

  ping : () ->
    r = fdb.current.response
    if r?
      gid = $(r).attr('marker')
      $.get 'germane/comments', { g: gid }, (data) -> fdb.update.history(data), 
      'json'
    return true


  #############################################################
  ## Update Methods 
  #############################################################

  update : {
    ticker : () ->
      for m in ['student', 'response']
        ref = $(fdb.current[m])
        val = ref.attr 'tag'
        node = $(shadow.root).find("#ticker-#{m}")
        node.text val
        if ref.hasClass('graded') then node.addClass('graded') else node.removeClass('graded')
      return true

    view : (clearOverlay = true) ->
      # To be called when fdb.current.scan changes value => switching from one scan to the next
      overlay.clear() if clearOverlay is true
      preview.load fdb.current.scan, 'locker'
      fdb.update.ticker()
      shadow.fall $(fdb.current.response).attr('shadow')
      return true

    history : (json) ->
      # The returned JSON has just the non-trivial comments - the only type we want 
      # to keep. Hence, with every periodic update, any trivial comments written 
      # in the last 5 min will be lost. And that's ok

      fdb.history.length = 0
      for a in json.comments 
        b = karo.unjaxify a
        fdb.history.push b
      return true

  }

  #############################################################
  ## Find ( general traversal )
  #############################################################

  find : {
    student : (fwd) -> # if fwd = true, then look for next, else look for previous
      current = fdb.current.student
      return null unless current?

      tag = $(current).attr 'tag'
      cnd = if fwd then $(current).nextAll() else $(current).prevAll()

      result = cnd.filter(":not([tag=#{tag}])")[0]
      if result? 
        fdb.current.student = result
        fdb.current.response = $(result).children()[0]
        fdb.current.scan = $(result).attr 'marker'
        fdb.update.view()
      else
        if fwd then notifier.show('n-last-scan') else notifier.show('n-first-scan')
      return result

    scan : (fwd) -> # if fwd = true, then look for next else look for previous 
      fdb.find.student(fwd)
      return fdb.current.scan

    response : (fwd) -> # if fwd = true, then look for next else look for previous
      c = fdb.current.response
      result = if fwd then $(c).next()[0] else $(c).prev()[0]

      if result?
        fdb.current.response = result # on the same scan 
        fdb.update.ticker()
        shadow.fall $(fdb.current.response).attr('shadow') if fdb.current.response?
      else
        p = if fwd then $(c).parent().next()[0] else $(c).parent().prev()[0]
        if p?
          fdb.current.student = p 
          fdb.current.response = $(p).children()[0] 
          fdb.current.scan = $(p).attr 'marker'
          fdb.update.view()
        else
          if fwd then notifier.show('n-last-scan') else notifier.show('n-first-scan')
      return true

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

  ###
    Shared behaviour 
  ###

  fdb.nav.on 'click', 'button', (event) ->
    event.stopImmediatePropagation()
    rubric.keyboard = true
    id = $(this).attr 'id'
    switch id 
      when 'btn-prev-ques'
        fdb.prev.response()
      when 'btn-next-ques'
        fdb.next.response()
      when 'btn-prev-scan'
        fdb.prev.scan()
      when 'btn-next-scan'
        fdb.next.scan()
    return  true
    
  fdb.controls.on 'click', 'button', (event) ->
    event.stopImmediatePropagation()
    return false if $(this).hasClass 'disabled'

    rubric.keyboard = true
    id = $(this).attr 'id'
    fdb.tex = null

    allButtons = fdb.controls.find("button:not([id='btn-hide-controls'])")
    $(m).removeClass('active') for m in allButtons 
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
        $.get "reset/graded?id=#{$(fdb.current.response).attr 'marker'}" # will also destroy any associated comments
      when 'btn-rotate'
        event.stopImmediatePropagation()
        $.get "rotate_scan.json?id=#{fdb.current.scan}"
      when 'btn-write'
        rubric.keyboard = false
        fdb.mode = 'comments'
        $(shadow.commentBox).focus()
        $(this).addClass 'active'
      when 'btn-perfect'
        event.stopImmediatePropagation()
        rubric.rewind()
        rubric.select(3)
        rubric.select(4)
        rubric.select(5)
      when 'btn-blank'
        event.stopImmediatePropagation()
        rubric.rewind()
        rubric.select(0)
        rubric.select(0)
        rubric.select(0)
      when 'btn-cheated'
        event.stopImmediatePropagation()
        rubric.rewind()
        rubric.select(1)
        rubric.select(0)
        rubric.select(0)
      when 'btn-hide-controls'
        isClicked = $(this).hasClass 'active'
        btnGroups = $(this).closest('.row-fluid').siblings() 
        if isClicked 
          next = 'Hide'
          $(j).removeClass('hide') for j in btnGroups
          $(this).removeClass 'active'
          shadow.unhide()
        else
          next = 'Unhide'
          $(j).addClass('hide') for j in btnGroups 
          $(this).addClass 'active'
          shadow.hide()
        $(this).text next
        $("<span class='kb-shortcut'>I</span>").prependTo $(this)

    return true # end of method

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
        c = $(shadow.commentBox).val()
        $(shadow.commentBox).val '' # clear it 
        unique = true
        for m in fdb.history 
          if m is c
            unique = false 
            break
        fdb.history.push c if unique 
        fdb.add c, event 

    return true
    
