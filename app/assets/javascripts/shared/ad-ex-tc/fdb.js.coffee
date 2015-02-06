
window.fdb = {
  root : null,
  list : null,
  controls: null, 
  nav: null,
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
    # p = $(fdb.root).find('#fdb-preview-area').eq(0)
    preview.attach $(fdb.root)
    overlay.attach $(preview.root)
    shadow.over $(overlay.root)

    $(fdb.root).removeClass 'hide'
    fdb.update.ticker()

    unless fdb.ticker?
      fdb.ticker = window.setInterval () -> fdb.ping(), 
      300000 # 5 min 
    return true

  detach : () ->
    preview.detach() # within wide-X
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
      if clearOverlay
        overlay.clear() 
        fdb.update.ticker()
      preview.load fdb.current.scan, 'locker'
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

  #############################################################
  ## Key Press Processing   
  #############################################################
  
  pressKey : (event) ->
    # 'event' propagation was stopped within rubric.pressKey() before 
    # execution came here. Hence, there is little need to call 
    # event.stopImmediatePropagation() here 

    key = event.which 
    # alert key
    switch key
      when 72 # H => hide/unhide controls 
        controls = fdb.controls.children()
        hideBtn = controls.eq(0).find('button')
        if hideBtn.hasClass 'active' 
          hideBtn.removeClass 'active'
          hideBtn.text 'Hide'
          $("<span class='kb'>H</span>").prependTo hideBtn
          shadow.unhide()
          $(m).removeClass('hide') for m in controls.filter(":not(:first-child)")
        else 
          hideBtn.addClass 'active'
          hideBtn.empty() 
          hideBtn.text 'Unhide'
          $("<span class='kb'>H</span>").prependTo hideBtn
          shadow.hide()
          $(m).addClass('hide') for m in controls.filter(":not(:first-child)")
      when 76 # L => re-upload / re-send scan. Also triggers mail to student 
        fdb.clear()
        mdl = $('#m-reupload')
        aid = $(fdb.current.response).attr 'marker'
        mdl.find('form').eq(0).attr 'action', "reupload?id=#{aid}"
        mdl.modal 'show'
      when 82 # R => restore pristine copy 
        fdb.clear()
        $.get "reset/graded?id=#{$(fdb.current.response).attr 'marker'}" # will also destroy any associated comments
      when 83 # S => submit feedback 
        $(rubric.form).submit() 
      when 87 # W => write a comment 
        $(shadow.commentBox).focus()
      when 85 # U => clear last entered comment 
        fdb.pop()
      when 70 # F => flip the image 
        $.get "rotate_scan.json?id=#{fdb.current.scan}"
      when 219 # [ => previous page 
        fdb.prev.scan()
      when 188 # < => previous question 
        fdb.prev.response()
      when 190 # > => next question 
        fdb.next.response()
      when 221 # ] => next page 
        fdb.next.scan()
    return true 

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
    fdb.controls.hover () ->
      $(this).stop().fadeTo('slow', 0)
    , () ->
      $(this).stop().fadeTo('slow', 1)
  
  $('#m-reupload form').on 'submit', -> 
    chkd = false 
    for cbx in $(this).find("input[type='checkbox']")
      chkd ||= $(cbx).prop('checked')
      break if chkd 
    return chkd
