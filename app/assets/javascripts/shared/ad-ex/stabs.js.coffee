
# <div q=a v=b stb=c> --> stab 
#   <div p=d kgz=e> --> kaagaz

TeX = (x,y,tex) ->
  this.x = x 
  this.y = y 
  this.tex = tex 

window.stabs = { 
  root: null, 
  form: null, 
  cmntBox : null,
  locked : false, 
  typing : false,
  buttons : null, 

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
      $(stabs.form).submit ->
        isFull = stabs.notepad.isFull() 
        if isFull 
          stabs.notepad.buildForm() 
        else 
          notifier.show 'n-missing-comments'
        return isFull

      # where TeX is written 
      stabs.cmntBox = $(stabs.root).find("input[id='stab-typeahead']")[0]
      $(stabs.cmntBox).typeahead { source: stabs.typeahead.list }

      # All buttons in the grading panel  
      stabs.buttons = $(stabs.root).find('button[data-kb], div[data-kb]')

      # Slider 
      stabs.slider.obj = $(stabs.root).find('#stabs-slider')[0]
      $(stabs.slider.obj).children('[title]').tooltipster( { trigger: 'custom', autoClose: false })

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

  show : { 
    stab : (stb) -> 
      # Shows the first scan 
      scans = $(stb).children()
      stabs.show.scan scans[0]
      # Disables next / previous buttons - if only one scan
      if scans.length is 1 
        $(btn).addClass('disabled') for btn in stabs.buttons.filter("[data-kb='>'],[data-kb='<']")
      return true  

    scan : (kgz) ->
      img = kgz.getAttribute 'p'
      overlay.clear() 
      preview.load img, 'locker', '#wide-Y'
      comments = stabs.notepad.comments kgz 
      if comments? 
        for j in comments 
          jxf = karo.jaxify j.tex 
          overlay.add(jxf, null, j.x, j.y) 
      return true  

    solution : () -> # always to the current stab
      stb = stabs.current.stab
      return false unless stb? 
      overlay.clear()
      q = stb.getAttribute 'q'
      v = stb.getAttribute 'v'
      $.get "question/preview?id=#{q}&v=#{v}", (json) ->
        preview.loadJson json, '#wide-Y'
      return true 
  } 

  ######## Typeahead ######### 

  typeahead : { 
    list : new Array(), # only *** unjaxified *** comments 

    push : (comment) -> # with duplicity checks  
      already = false
      for j in stabs.typeahead.list 
        already |= (j is comment) 
        break if already
      stabs.typeahead.list.push(comment) unless already 
      return true 

    ping : (stab) -> 
      # Call everytime the stab changes 
      q = stab.getAttribute 'q'
      $.get "question/commentary?id=#{q}", (json) -> 
        stabs.typeahead.load json
      return true 

    load : (json) -> 
      # Call from within ping() only 
      stabs.typeahead.clear()
      for j in json.comments 
        unjxf = karo.unjaxify j
        stabs.typeahead.push unjxf
      return true 

    clear : () -> 
      # Call from within load() only
      stabs.typeahead.list.length = 0
      return true 

  } 

  ######## Notepad - for just added comments  ######### 
  notepad : { 
    list  : new Object(), 
    # key = kaagaz-db-id, value = array of hashes = [{ :x, :y, :tex }]
    # TeX = *** unjaxified *** only

    clear : () -> 
      delete stabs.notepad.list[k] for k in Object.keys(stabs.notepad.list)
      overlay.clear()
      head = $(stabs.form).children('.hide')[0]
      $(head).empty() 
      return true 

    push : (comment, event) ->
      # comment = TeX as entered by the grader => unjaxified 
      return false unless event? 
      [xp, yp] = overlay.offsets(event) 
      return false if xp is null or yp is null # click outside overlay

      kgz = stabs.current.scan 
      return false unless kgz? 

      cmts = stabs.notepad.comments(kgz) 
      id = kgz.getAttribute('kgz') 

      unless cmts? 
        stabs.notepad.list[id] = new Array() 
        cmts = stabs.notepad.list[id]

      sntz = karo.sanitize comment
      return false unless sntz.length # ignore blank comments 
      cmts.push(new TeX(xp, yp, sntz))

      jxf = karo.jaxify sntz 
      overlay.add jxf, null, xp, yp 
      return true 

    pop : () -> # remove last added TeX comment from current scan
      kgz = stabs.current.scan 
      return false unless kgz?
      comments = stabs.notepad.comments(kgz)
      return false unless comments?

      last = comments.pop() 
      overlay.pop() if last?
      return true

    comments : (kgz) -> # kgz = HTML obj as created by stabs.pending.load 
      k = kgz.getAttribute 'kgz'
      onScan = stabs.notepad.list[k] # an array of TeX comments on kaagaz with kgz=k 
      return onScan

    isFull : () ->
      # returns true if every scan of the stab has > 1 comments. Else false 
      nKgz = $(stabs.current.stab).children().length
      pgs = Object.keys(stabs.notepad.list)
      return false if (nKgz > pgs) # => not all Scan annotated 

      # Or, the annotations could all have been popped leaving nothing 
      allDone = true 
      for k in pgs 
        allDone &= (stabs.notepad.list[k].length > 0)
        break unless allDone
      return allDone

    buildForm : () ->
      # Low on sanity checks. Assumes you know when you're calling it.
      head = $(stabs.form).children('.hide')[0]
      list = stabs.notepad.list 
      keys = Object.keys(list)

      for kgzId in Object.keys(list) 
        for cmnt,n in list[kgzId] 
          for field in Object.keys(cmnt) 
            if field isnt 'tex'
              $("<input type='number' value='#{cmnt[field]}' name='kgz[#{kgzId}][#{n}][#{field}]'>").appendTo $(head)
            else
              tex = karo.jaxify cmnt[field]
              # tex = encodeURIComponent(tex)
              $("<input type='text' value=\"#{tex}\" name='kgz[#{kgzId}][#{n}][#{field}]'>").appendTo $(head)
      return true
  }


  ######## Slider ######### 

  slider : { 
    obj : null, 
    tooltips : ['Blank / little done', 
                'Unimpressed', 
                'Mildly impressed', 
                'Reasonably impressed', 
                'Quite impressed', 
                'Very impressed / Perfect']

    select : (key) ->
      return false unless stabs.slider.obj?
      bbl = $(stabs.slider.obj).children("[data-kb='#{key}']")[0]
      if bbl?
        others = $(bbl).siblings('[data-kb]')
        for d in others 
          $(d).removeClass 'active'
          $(d).children('input').prop 'checked', false
          $(d).tooltipster 'hide'

        index = parseInt(key) - 1
        tip = stabs.slider.tooltips[index]

        $(bbl).addClass 'active'
        $(bbl).children('input').prop 'checked', true
        $(bbl).tooltipster('content', tip).tooltipster('show')
      return true 
  } 

  ######## Pending ######### 

  pending : { 
    list : null, 

    clear : () -> 
      $(stabs.pending.list).empty() if stabs.pending.list?
      stabs.current.stab = null 
      stabs.current.scan = null
      return true 

    load : (json) -> 
      return false unless stabs.pending.list?
      return false unless json.stabs?

      stabs.pending.clear() 
      for j in json.stabs 
        stb = $("<div q=#{j.q} v=#{j.v} stb=#{j.id}></div>").appendTo $(stabs.pending.list)
        for kgz in j.scans
          $("<div p=#{kgz.path} kgz=#{kgz.id}></div>").appendTo(stb) # kgz = Kaagaz model

      stabs.pending.next.stab() 
      return true 

    next : { 
      stab : () ->
        # Grader can't move from one stab to the next without grading the first one!
        # However, he can move from one scan to the next within the same stab
        stabs.notepad.clear() 
        curr = stabs.current.stab
        if curr?
          nextStb = $(curr).next()[0]
          $(curr).remove()
        else 
          nextStb = $(stabs.pending.list).children()[0] 

        if nextStb? 
          nextScn = $(nextStb).children()[0]
          stabs.typeahead.ping nextStb
          stabs.show.stab nextStb
          stabs.slider.select '3'
        else 
          # last stab
          nextScn = null
          notifier.show 'n-last-scan'

        stabs.current.stab = nextStb 
        stabs.current.scan = nextScn
        return true

      scan : () ->
        n = $(stabs.current.scan).next()[0]
        if n? 
          stabs.current.scan = n 
          stabs.show.scan(n)
        return n 
    } 

    prev : { 
      scan : () ->
        p = $(stabs.current.scan).prev()[0]
        if p? 
          stabs.current.scan = p 
          stabs.show.scan(p)
        return p
    } 
  } 

  ######## Key-presses and Mouse clicks  ######### 

  pressKey : (event) ->
    return true if (stabs.locked || stabs.typing)
    event.stopImmediatePropagation() 

    return true unless stabs.current.stab? # no stab => no point doing anything 
    key = String.fromCharCode(event.which).toLowerCase()

    btn = stabs.buttons.filter("[data-kb=#{key}]")[0]
    return false unless (btn? and not $(btn).hasClass('disabled'))

    switch event.which 
      when 81 # Q
        rest = stabs.buttons.filter(":not([data-kb='q'],[data-kb='s'])")
        if $(btn).hasClass 'active'
          $(btn).removeClass 'active' 
          $(b).removeClass('disabled') for b in rest
          stabs.show.stab(stabs.current.stab)
        else 
          $(btn).addClass 'active'
          $(b).addClass('disabled') for b in rest
          stabs.show.solution()
      when 65 # A
        return true
      when 87 # W 
        $(stabs.cmntBox).focus()
        stabs.typing = true
      when 85 # U
        stabs.notepad.pop()
      when 70 # F
        scn = stabs.current.scan
        pth = if scn? then scn.getAttribute('p') else null 
        if pth?
          $(btn).addClass 'active'
          $.get "rotate_scan?id=#{pth}", (json) ->
            $(btn).removeClass 'active'
            stabs.pending.next.stab()
      when 82 # R
        return true
      when 83 # S => submit form 
        $(stabs.form).submit()
      else 
        stabs.slider.select(key) if (event.which > 48 and event.which < 55) # 1-6

    return true 

  mouseClick : (event) ->
    return true if stabs.locked 
    tex = $(stabs.cmntBox).val() 

    $(stabs.cmntBox).val ''
    if stabs.notepad.push(tex, event) # to be stored in the DB 
      stabs.typeahead.push tex # locally stored to help with auto-completion 
    stabs.typing = false
    return true 
} 
