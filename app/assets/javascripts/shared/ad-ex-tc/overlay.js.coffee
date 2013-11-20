
window.overlay = {
  root : null, 
  nComments: 0,
  counter: 0, # only moves forward 
  ref : null,
  xp: null, 
  yp: null, # specified as style attribute ( left: xp, top: yp )
  tex: null,

  over : (obj) ->
    obj = if typeof obj is 'string' then $(obj) else obj 
    id = obj.attr('id')
    id = if id? then "overlay-#{id}" else "overlay-X"

    $(overlay.root).remove() if overlay.root? 
    transparentObj = $("<div id=#{id} class='overlay'></div>").insertAfter obj

    overlay.root = transparentObj
    overlay.nComments = 0
    overlay.counter = 0
    overlay.ref = $('#wide')[0] unless overlay.ref?  # all overlays rendered within #wide 
    return true

  clear : () ->
    return false unless overlay.root?
    return false if overlay.nComments < 1

    overlay.nComments = 0
    $(overlay.root).empty()
    return true

  loadJson : (json) ->
    ###
      json = [{ x:< > , y:< > , comment: < > } ... { ... } ]
    ###
    overlay.add(m.comment, null, m.x, m.y) for m in json
    return true

  add : (comment, event = null, xp = null, yp = null) ->
    # Do nothing if overlay is hidden as it (the overlay) is not intended to be used
    return false if $(overlay.root).hasClass 'hide'
    
    # Either event = nil || (xp,yp) = (nil,nil)
    if event? 
      ###
        The offset keeps on changing depending on the zoom applied in the browser. 
        The surest way to ensure consistent behaviour is, therefore, to calculate 
        the offset just when processing the click
      ###
      offset = $(overlay.ref).offset()
      x = event.pageX - offset.left 
      y = event.pageY - offset.top - 50 # bit of a hack

      return false if (x < 0 || y < 0) # click outside of overlay
      xp = Math.round (x / 6)
      yp = Math.round (y / 8)

      # Store the x- and y- offset percentages. These are more for other modules to use
      overlay.xp = xp
      overlay.yp = yp

      # Ignore blank comments 
      unless (comment.length and comment.match(/\S/)) 
        overlay.xp = null
        overlay.yp = null
        return false

      # Prepare comment for MathJax 
      comment = karo.sanitize comment
      overlay.tex = karo.jaxify comment
      overlay.nComments += 1
      overlay.counter += 1
    else 
      overlay.tex = comment
      # Only the jaxified version of the comment is stored in the DB
      
    # Prepare the <script> to pass to MathJax 
    id = "tex-comment-#{overlay.counter}"
    script = $("<script id=#{id} type='math/tex'>#{overlay.tex}</script>")
    $(script).appendTo $(overlay.root)
    MathJax.Hub.Queue ['Typeset', MathJax.Hub, "#{id}"], [overlay.writeTex, script, xp,yp]
    return true

  pop : () ->
    # Remove last added comment => last added <script> and <span>
    return false if overlay.nComments < 1
    overlay.nComments -= 1

    c = $(overlay.root).children()
    c.filter("#{m}:last").remove() for m in ['span','script']
    return true

  writeTex : (script, xp, yp) ->
    # (xp, yp) = offsets - expressed as percentage - from left and top respectively
    tex = script.prev('span')
    tex.attr 'style', "left:#{xp}%;top:#{yp}%;"
    return true

}
