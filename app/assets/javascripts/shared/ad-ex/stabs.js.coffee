
# <div q=a v=b marker=c> --> stab 
#   <div p=d marker=e> --> scan

TeX = (x,y,tex) ->
  this.x = x 
  this.y = y 
  this.tex = tex 

window.stabs = { 
  root: null, 
  form: null, 
  locked : false, 
  typing : false,

  ######## Current Stab and Scan ######### 

  current : { 
    stab : null, 
    scan : null
  }

  ######## Setting Up ######### 

  initialize : () ->
    unless stabs.root?
      stabs.root = $('#stabs-grader')[0] 
      stabs.pending.list = $(stabs.root).children('#stabs-pending')[0]
      stabs.form = $(stabs.root).find('form')[0]

    # An examiner sees two rubrics - this one (will stay) and one for 
    # schools (will go in time). As both share keyboard shortcuts, we must ensure 
    # that only the last initialized rubric processes key-presses and mouse-clicks 

    rubric.lock()
    stabs.unlock() 
    return true 

  lock : () ->
    stabs.locked = true 
    $('body').off 'keyup', stabs.pressKey 
    $('body').off 'click', stabs.mouseClick 
    overlay.detach()
    preview.detach()
    return true 

  unlock : () ->
    stabs.locked = false 
    $('body').on 'keyup', stabs.pressKey 
    $('body').on 'click', stabs.mouseClick 
    preview.attach '#wide-Y'
    overlay.attach('#wide-Y', true)
    return true

  showScan : (scan) ->
    img = scan.getAttribute 'p'
    overlay.clear() 
    preview.load img, 'locker'
    comments = stabs.notepad.comments scan 
    if comments? 
      overlay.add(j.tex, null, j.x, j.y) for j in comments 
    return true  

  ######## Typeahead ######### 

  typeahead : { 
    list : new Array(), # only *** unjaxified *** comments 

    add : (comment) -> # with duplicity checks  
      unique = true
      for j in stabs.typeahead.list 
        unique = not j is comment
        break unless unique 
      stabs.typeahead.list.push(comment) if unique
      return true 

    ping : () -> 
      # Call everytime the stab changes 
      return true 

    load : (json) -> 
      # Call from within ping() only 
      return true 

    clear : () -> 
      # Call from within load() only
      stabs.typeahead.list.length = 0
      return true 

  } 

  ######## Notepad - for just added comments  ######### 
  notepad : { 
    stuff  : new Object(), 
    # key = scan-db-id, value = array of hashes = [{ :x, :y, :tex }]
    # TeX = *** unjaxified *** only

    clear : () -> 
      delete stabs.notepad.stuff[k] for k in stabs.notepad.stuff.keys()
      overlay.clear()
      return true 

    push : (comment, event) ->
      # comment = TeX as entered by the grader => unjaxified 
      return false unless event? 
      scan = stabs.current.scan 
      return false unless scan? 

      cmts = stabs.notepad.comments(scan) 
      id = scan.getAttribute('marker') 

      unless cmts? 
        cmts = new Array() 
        stabs.notepad.stuff[id] = cmts 

      [xp, yp] = overlay.offsets(event) 

      sntz = karo.sanitize comment
      jxf = karo.jaxify c 

      n = cmts.length() # number of elements till now 
      cmts.push TeX.new(xp, yp, sntz)
      overlay.add jxf, null, xp, yp 
      return true 

    pop : () -> # remove last added TeX comment from current scan
      scan = stabs.current.scan 
      return false unless scan?
      comments = stabs.notepad.comments(scan)
      return false unless comments?

      last = comments.pop() 
      if last?
        destroy last 
        overlay.pop()
      return true

    comments : (scan) -> # scan = HTML obj as created by stabs.pending.load 
      k = scan.getAttribute 'marker'
      onScan = stabs.notepad.stuff[k] # an array of TeX comments on scan with marker=k 
      return onScan
  }

  ######## Pending ######### 

  pending : { 
    list : null, 

    clear : () -> 
      $(stabs.pending.list).empty() if stabs.pending.list?
      return true 

    load : (json) -> 
      return false unless stabs.pending.list?
      return false unless json.dated?

      stabs.pending.clear() 
      for j in json.dated 
        stb = $("#<div q=#{j.q} v=#{j.v} marker=#{j.id}></div>").appendTo $(stabs.pending.list)
        for kgz in j.scans
          $("<div p=#{kgz.path} marker=#{kgz.id}></div>").appendTo(stb) 

      stabs.current.stab = $(stabs.pending.list).children()[0]
      stabs.current.scan = $(stabs.current.stab).children()[0]
      return true 

    nextScan : () -> 
      n = $(stabs.current.scan).next()[0]
      if n? 
        stabs.current.scan = n 
        stabs.showScan(n)
      return n 

    prevScan : () ->
      p = $(stabs.current.scan).prev()[0]
      if p? 
        stabs.current.scan = p 
        stabs.showScan(p)
      return p

  } 

  ######## Key-presses and Mouse clicks  ######### 

  pressKey : (event) ->
    return true if (stabs.locked || stabs.typing)

    event.stopImmediatePropagation() 
    key = String.fromCharCode(event.which)
    # alert "stabs --> #{event.which} --> #{key}"
    return true 

  mouseClick : (event) ->
    return true if stabs.locked 
    return true 
} 
