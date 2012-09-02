
window.canvas = {
  blockKeyPress: false,
  object: null,
  ctx: null,
  clicks: null,
  xoff: 0,
  yoff: 0,
  last:0, # insert before updating index 

  initialize: (id) ->
    canvas.object = if typeof id is 'string' then $(id) else id
    canvas.ctx = canvas.object[0].getContext('2d')
    offset = canvas.object.offset()
    canvas.xoff = offset.left
    canvas.yoff = offset.top
    canvas.clicks = new Array()

    return true
    

  load : (scan) ->
    # 'scan' is a jQuery object provided by abacus as abacus.last.scan

    # Clear 'clicks' array for the new canvas image 
    canvas.clear() if canvas.clicks?
    ctx = canvas.ctx
    image = new Image()
    src  = scan.attr 'name'
    tokens = src.split '-'
    folder = "#{tokens[0]}-#{tokens[1]}"

    image.onload = () ->
      ctx.drawImage(image,15,0)
      ctx.strokeStyle="#fd9105"
      ctx.lineJoin="round"

    image.src = "#{gutenberg.server}/locker/#{folder}/#{src}"
    return true

  # n: 0-indexed
  loadNth: (n, list = '#pending-scans') ->
    list = $(list).find('.purgeable:first')
    
    # Clear 'clicks' array for the new canvas image 
    canvas.clear() if canvas.clicks?

    ctx = canvas.ctx
    image = new Image()
    scanDiv = list.children('div[scan]').eq(n)
    src = scanDiv.attr 'scan'
    tokens = (scan.attr 'name').split '-'
    folder = "#{tokens[0]}-#{tokens[1]}"

    image.onload = () ->
      ctx.drawImage(image,15,0)
      ctx.strokeStyle="#fd9105"
      ctx.lineJoin="round"
    image.src = "#{gutenberg.server}/locker/#{folder}/#{src}"

    ###
      If the grading-panel is in the side panel, then: 
        1. display the appropriate # of grd-sliders (max 4)
        2. change the 'name' attribute of the (hidden) input[type="number"]
           field that is tied to the slider
    ###
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

        ###
          Two things need to be done now:
            1. Bind the radio-buttons to <label> so that buttonset() can work properly
            2. For each graded response on the scanned page, set the *same*
               'name' attribute on each of the grade radio-buttons. The value
               submitted has already been defined in the toolbox
        ###

        for radio,index in c.children 'input[type="radio"]'
          $(radio).attr 'name', "grade[#{response_id}]"
          label = $(radio).next 'label'
          v = "grd-#{response_id}-#{index}"
          $(radio).attr 'id', "#{v}"
          label.attr 'for', "#{v}"
    return true

  record: (event) ->
    x = event.pageX - canvas.xoff
    y = event.pageY- canvas.yoff

    return if x < 0 || y < 0 # click not inside canvas
    # alert "(#{event.pageX}, #{canvas.xoff}) --> #{x} ---> #{y}"

    last = canvas.last
    canvas.clicks[last] = [x,y]
    canvas.last += 1

    if (last % 2) is 1
      first = canvas.clicks[last-1] #first click
      second = canvas.clicks[last] # second click

      rect = canvas.calcRectangle first, second
      ctx = canvas.object[0].getContext('2d')
      ctx.strokeRect rect.x, rect.y, rect.width, rect.height
    return true
    
  clear: () ->
    # The better way to clear a JS array is to set its length to 0
    canvas.clicks.length = 0 if canvas.clicks?
    canvas.last = 0

  undo: () ->
    if canvas.last % 2 is 1
      canvas.clicks.pop()
      canvas.last -= 1
    else
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
    return true
  
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
