
window.canvas = {
  blockKeyPress: false,
  object: null,
  ctx: null,
  clicks: null,

  checks : null,
  crosses : null,
  exclamations : null,
  mode : null,

  xoff: 0,
  yoff: 0,
  last:0, # insert before updating index 
  colour : {
    red : "#ff0000",
    orange : "#ffa500",
    green : "#168816",
    white : "#ffffff",
    pink : "#e3105a",
    last : null
  }

  initialize: (id) ->
    canvas.object = if typeof id is 'string' then $(id) else id
    canvas.ctx = canvas.object[0].getContext('2d')
    canvas.ctx.lineCap = "round"
    canvas.ctx.lineJoin = "round"
    canvas.ctx.lineWidth = 3
    offset = canvas.object.offset()
    canvas.xoff = offset.left
    canvas.yoff = offset.top

    canvas.clicks = new Array()
    canvas.checks = new Array()
    canvas.crosses = new Array()
    canvas.exclamations = new Array()

    return true
    

  load : (scan) ->
    # 'scan' is a jQuery object provided by abacus as abacus.last.scan

    # Clear 'clicks' array for the new canvas image 
    canvas.clear() if canvas.clicks?
    ctx = canvas.ctx
    image = new Image()
    src  = scan.attr 'name'

    image.onload = () ->
      ctx.drawImage(image,15,0)

    image.src = "#{gutenberg.server}/locker/#{src}"
    return true

  underline : (draw = true) ->
    last = canvas.last
    from = canvas.clicks[last-2]
    to = canvas.clicks[last-1]
    ctx = canvas.ctx

    ctx.strokeStyle = if draw is true then canvas.colour.last else canvas.colour.white
    ctx.beginPath()
    ctx.moveTo from[0], from[1]
    ctx.lineTo to[0], to[1]
    ctx.stroke()
    return true

  drawMark : (mode, draw = true) ->
    return false unless mode?
    ctx = canvas.ctx

    ctx.strokeStyle = if draw is true then canvas.colour.last else canvas.colour.white
    switch mode
      when 'checks' then pts = canvas.checks.slice -8
      when 'crosses' then pts = canvas.crosses.slice -8
      when 'exclamations' then pts = canvas.exclamations.slice -8

    for j in [0..1]
      start = 4*j
      ctx.beginPath()
      ctx.moveTo pts[start], pts[start + 1]
      ctx.lineTo pts[start + 2], pts[start + 3]
      ctx.stroke()
    return true


  record: (event) ->
    return false unless canvas.mode?
    x = event.pageX - canvas.xoff
    y = event.pageY- canvas.yoff

    return if x < 0 || y < 0 # click not inside canvas
    # alert "(#{event.pageX}, #{canvas.xoff}) --> #{x} ---> #{y}"

    switch canvas.mode
      when 'checks'
        canvas.checks.push x-3,y-4,x,y,x,y,x+5,y-12 # pythagoras triplets
      # when 'crosses'
      # when 'exclamations'
    canvas.drawMark 'checks'
    return true

    ###
    last = canvas.last
    canvas.clicks[last] = [x,y]
    canvas.last += 1

    if (last % 2) is 1
      canvas.underline()
    ###
    
  clear: () ->
    # The better way to clear a JS array is to set its length to 0
    canvas.clicks.length = 0 if canvas.clicks?
    canvas.checks.length = 0 if canvas.checks?
    canvas.crosses.length = 0 if canvas.crosses?
    canvas.exclamations.length = 0 if canvas.exclamations?
    canvas.last = 0

  undo: () ->
    if canvas.last % 2 is 1
      canvas.clicks.pop()
      canvas.last -= 1
    else
      canvas.underline false
      canvas.last -= 2
      ###
      last = canvas.last
      rect = canvas.calcRectangle canvas.clicks[last-1], canvas.clicks[last-2]
      canvas.last -= 2

      # We choose in 'invert' of the colour we drew the original line in
      # It is the colour that when overlaid would produce white
      canvas.ctx.strokeStyle = "#026efa"
      canvas.ctx.globalCompositeOperation = "lighter"
      canvas.ctx.strokeRect rect.x, rect.y, rect.width, rect.height

      # Now, revert back to original stroke style
      canvas.ctx.strokeStyle = "#fd9105"
      canvas.ctx.globalCompositeOperation = "source-over"
      ###
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
    for pt in canvas.clicks
      ret += "_#{pt[0]}_#{pt[1]}" # pt[0] = x, pt[1] = y
    return ret

###
  calcRectangle: (first, second) -> # points are of the form [x,y]
    rectangle = { x:null, y:null, width:null, height:null }

    if first[0] > second[0] # comparing x-coordinates
      rectangle.x = second[0]
      rectangle.width = first[0]-second[0]
    else
      rectangle.x = first[0]
      rectangle.width = second[0] - first[0]

    if first[1] > second[1] # comparing y-coordinates
      rectangle.y = second[1]
      rectangle.height = first[1]-second[1]
    else
      rectangle.y = first[1]
      rectangle.height = second[1] - first[1]

    return rectangle

  # n: 0-indexed
  loadNth: (n, list = '#pending-scans') ->
    list = $(list).find('.purgeable:first')
    
    # Clear 'clicks' array for the new canvas image 
    canvas.clear() if canvas.clicks?

    ctx = canvas.ctx
    image = new Image()
    scanDiv = list.children('div[scan]').eq(n)
    src = scanDiv.attr 'scan'

    image.onload = () ->
      ctx.drawImage(image,15,0)
      ctx.strokeStyle="#fd9105"
      ctx.lineJoin="round"
    image.src = "#{gutenberg.server}/locker/#{src}"

    if $('#side-panel').find('#grading-panel').length isnt 0
      responses = scanDiv.children('div[response_id]')
      nResponses = responses.length # should be <= 4

      gradeControls = $('#grade-controls')
      nonMcq = $('#toolbox').find '.grade-btns-non-mcq:first'
      mcq = $('#toolbox').find '.grade-btns-mcq:first'

      gradeControls.empty() # purge any previous controls
      for i in [0...nResponses]
        rDiv = responses.eq(i)
        isMcq = if rDiv.attr('mcq') is "true" then true else false
        response_id = rDiv.attr 'response_id'

        # Append a div to display the question # just before the grade controls
        $("<div class='grading-panel-question-label'>#{rDiv.attr('qlabel')}</div>").appendTo gradeControls

        c = if isMcq then mcq.clone() else nonMcq.clone()
        c.appendTo gradeControls
        #c.children('input[type="number"]:first').attr 'name', "grade[#{response_id}]"

        for radio,index in c.children 'input[type="radio"]'
          $(radio).attr 'name', "grade[#{response_id}]"
          label = $(radio).next 'label'
          v = "grd-#{response_id}-#{index}"
          $(radio).attr 'id', "#{v}"
          label.attr 'for', "#{v}"
    return true

  jump: (fwd = true, list = '#list-pending') ->
    list = if typeof list is 'string' then $(list) else list
    nScans = parseInt(list.attr 'length')
    current = parseInt(list.attr 'current')
    if fwd is true
      next = (current + 1) % nScans
    else
      next = if current > 0 then current - 1 else nScans - 1

    alert "Back to first .." if next is 0
    canvas.loadNth next
    list.attr 'current', "#{next}"
    return true


  scrollImg: (images, event) ->
    key = event.keyCode
    switch key
      when 66 then fwd = false # 'B' for going back to previous image 
      when 78 then fwd = true # 78 = 'N' for going to next image

    canvas.jump fwd
    return true


  scrollSidePnlList: (event) ->
###

}
