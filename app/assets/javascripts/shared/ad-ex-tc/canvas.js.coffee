
window.canvas = {
  blockKeyPress: false,
  object: null,
  ctx: null,

  glyph : {
    check : null,
    cross : null,
    question : null
  },

  clicks : {
    check : null,
    cross : null,
    question : null
  },

  colour : {
    white : "#ffffff",
    blue : "#1b13f1"
  }

  mode : null,
  comments : null,
  typeahead : new Array(),

  last:0, # insert before updating index 

  initialize: (id) ->
    canvas.object = if typeof id is 'string' then $(id) else id
    
    $(abacus.commentBox).typeahead {
      source : canvas.typeahead
    }

    # Canvas context settings
    canvas.ctx = canvas.object[0].getContext('2d')
    ###
    canvas.ctx.lineCap = "round"
    canvas.ctx.lineJoin = "round"
    canvas.ctx.lineWidth = 3
    ###

    for m in ['check', 'cross', 'question']
      canvas.glyph[m] = $("#toolbox > #annotation-marks > ##{m}mark")[0] unless canvas.glyph[m]?
      canvas.clicks[m] = new Array()

    canvas.comments = new Array()
    canvas.ctx.fillStyle = canvas.colour.blue
    canvas.ctx.strokeStyle = canvas.colour.blue
    canvas.ctx.font = "12px Ubuntu"
    return true
    

  load : (scan) ->
    # 'scan' is a jQuery object provided by abacus as abacus.current.scan

    # Clear any previously added check marks etc 
    canvas.clear()
    ctx = canvas.ctx
    image = new Image()
    src  = scan.attr 'name'

    # Scans for a testpaper are stored together within a folder in locker/ 
    # And the locker is named "quizId-testpaperId" - which we store as an attribute 
    # on the parent student object. Note that the code is here for a specific quiz.
    # And a quiz can be taken only once by a student

    folder = scan.parent().attr 'within' # stored as an attribute in the parent student

    image.onload = () ->
      ctx.drawImage(image,15,0)

    image.src = "#{gutenberg.server}/locker/#{folder}/#{src}"
    return true

  drawTex : (script, x, y) ->
    tex = script.prev('span')
    #tex.attr 'style', "position:relative;font-size:10px;left:#{x}px;top:#{y}px;color:#3f9129;"
    tex.attr 'style', "position:absolute;left:#{x}px;top:#{y}px;color:#3f9129;"
    return true

  sanitize : (comment) ->
    ret = comment.replace /[\$]+/g, '$' # -> all TeX within $..$ (inlined)
    # Make sure that all $'s are paired. Remember, the value this function returns 
    # is what will be typeset remotely. Can't have LaTeX barf there
    nDollar = (ret.match(/\$/g) || []).length

    if nDollar % 2 isnt 0 # => odd # of $ => mismatched
      ret += "$"
    return ret
    
  jaxify : (comment) ->
    ###
      The comment entered in the comment box is assumed to be more of regular 
      text with bits of inline-TeX thrown in ( enclosed between $..$ that is)

      But MathJax expects TeX that is more of TeX with bits of regular 
      text thrown in (enclosed between \text{...})

      This method does that conversion from the user assumes and enters 
      to what MathJax assumes and renders
    ###

    text = true
    latex = false
    z = "\\text{"

    for m in comment
      if text
        if m is '$' # opening $
          text = false
          latex = true
          z += " }"
        else
          z += m
      else if latex
        if m is '$' # => closing $
          text = true
          latex = false
          z += "\\text{ "
        else
          z += m
    z += "}" if text
    return z
    

  record: (event) ->
    return false unless canvas.mode?
    x = event.pageX - canvas.object[0].offsetLeft
    y = event.pageY- canvas.object[0].offsetTop

    return if x < 0 || y < 0 # click not inside canvas

    unless canvas.mode is 'comments'
      glyph = canvas.glyph[canvas.mode]
      clicks = canvas.clicks[canvas.mode]

      canvas.ctx.drawImage glyph, x - 7, y - 7
      clicks.push x - 7, y-7
    else
        comment = $(abacus.commentBox).val()
        return unless (comment.length and comment.match(/\S/)) # => ignore blank comments

        comment = canvas.sanitize comment
        jaxified = canvas.jaxify comment

        # Push only unique comments into typeahead
        unique = true
        for m in canvas.typeahead
          if m is comment
            unique = false
            break

        canvas.typeahead.push comment if unique
        
        # escape backslashes etc. that are otherwise disallowed in URI
        comment = encodeURIComponent comment

        index = if canvas.comments? then canvas.comments.length else 0
        id = "tex-fdb-#{index}"

        script = $("<script id=#{id} type='math/tex'>#{jaxified}</script>")
        $(script).appendTo canvas.object.parent()
        MathJax.Hub.Queue ['Typeset', MathJax.Hub, "#{id}"], [canvas.drawTex, script, event.pageX, event.pageY]
        
        canvas.comments.push x,y,comment
        
        # clear comment-box and get ready for next comment
        abacus.commentBox.val ''
        abacus.commentBox.focus() # take back focus
    return true
    
  clear: () ->
    # The better way to clear a JS array is to set its length to 0
    for m in ['check', 'cross', 'question']
      canvas.clicks[m].length = 0 if canvas.clicks[m]?
    canvas.comments.length = 0 if canvas.comments?
    
    # Unlike check-marks, crosses etc. - comments are rendered as HTML nodes by MathJax.
    # These needed to be removed from the DOM
    $(m).remove() for m in canvas.object.siblings 'span,script'
    canvas.last = 0

  undo: () ->
    unless canvas.mode is 'comments'
      # pop the last two entries - which are the (x,y) of last click
      clicks = if canvas.mode? then canvas.clicks[canvas.mode] else null
      if clicks?
        y = clicks.pop()
        x = clicks.pop()
        if x? and y?
          ctx = canvas.ctx
          ctx.fillStyle = canvas.colour.white
          ctx.fillRect x,y,16,16 # overwrite image with a white rectangle 
          ctx.fillStyle = canvas.colour.blue
    else if canvas.comments?
      comment = canvas.comments.pop()
      script = canvas.object.siblings('script:last')
      if script.length isnt 0
        span = script.prev()
        span.remove()
        script.remove()
    return true
  
  decompile: () ->
    ###
      Returns the list of points clicked on the canvas in the form: 
        a_b_c_d_e_f_g_h     ----> '_' is a separator
      It is understood that (a,b) and (c,d) are corners of one rectangle
      - as are (e,f) and (g,h). in the rails code, one always picks 
      pairs of points 
    ###
    ret = ""
    
    for type in ['cross', 'check', 'question']
      switch type
        when 'check'
          start = 'checkb'
          stop = 'checke'
        when 'cross'
          start = 'crossb'
          stop = 'crosse'
        when 'question'
          start = 'quesb'
          stop = 'quese'

      ret += "_#{start}"
      for p in canvas.clicks[type]
        ret += "_#{p}"
      ret += "_#{stop}"

    ###
      Comments are complicated because they can have any character in them. 
      They need to be therefore wrapped properly
    ###
    
    l = canvas.comments.length
    ret += "_commentb"

    for cmnts,index  in canvas.comments
      j = (index % 3)
      if (j < 2) # => 0 or 1
        ret += "_#{canvas.comments[index]}"
      else
        ret += "_#{canvas.comments[index]}" # => += _"comment string"
    ret += "_commente_"
    return ret

}

jQuery ->
  MathJax.Hub.Config {
    "HTML-CSS" : {
      styles : {
        ".mtext" : {
          "font-size" : "11px"
          "font-weight" : "300"
        },
        ".mo, .mrow .mn, .mrow .mi" : {
          "font-size" : "80%"
        }
      }
    }
  }
