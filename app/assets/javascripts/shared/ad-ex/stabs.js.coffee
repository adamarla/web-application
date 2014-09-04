

window.stabs = { 
  root: null, 
  form: null, 
  locked : false, 
  typing : false,

  ######## Setting Up ######### 

  initialize : () ->
    unless stabs.root?
      stabs.root = $('#stabs-grader')[0] 
      stabs.pending.list = $(stabs.root).children('#stabs-pending')[0]

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

  loadScan : (obj) ->
    img = obj.getAttribute 'p'
    preview.load img, 'locker'
    return true  

  ######## Form ######### 

  form : {
    clear : () -> 
      return true 

    add : (name = null) ->
      return true 
  } 


  ######## Typeahead ######### 

  typeahead : { 
    clear : () -> 
      return true 

    ping : () -> 
      return true 

    load : (json) -> 
      return true 
  } 

  ######## Notepad - for just added comments  ######### 
  notepad : { 
    stuff  : new Array(), 

    clear : () -> 
      stabs.notepad.stuff.length = 0 
      return true 

    notesOn : (scan) ->
      return null 
  }

  ######## History - for comments added historically  ######### 
  history : { 
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
        stabs.loadScan(n)
      return n 

    prevScan : () ->
      p = $(stabs.current.scan).prev()[0]
      if p? 
        stabs.current.scan = p 
        stabs.loadScan(p)
      return p

  } 

  ######## Current Stab and Scan ######### 

  current : { 
    stab : null, 
    scan : null
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
