
window.canvas = {

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
    canvas.clear()

    return true
    

  # n: 0-indexed
  loadNth: (n, list = '#ungraded-responses') ->
    list = $(list).find('ul:first')
    nImages = list.children('li').length
    return if nImages < 1
    
    n %= nImages
    ctx = canvas.ctx
    image = new Image()
    src = list.children('li').eq(n).text()
    image.onload = () ->
      ctx.drawImage(image,15,0)
      ctx.strokeStyle="#fd9105"
      ctx.lineJoin="round"
    image.src = "#{gutenberg.server}/locker/#{src}"

  record: (event) ->
    x = event.pageX - canvas.xoff
    y = event.pageY- canvas.yoff

    return if x < 0 || y < 0 # click not inside canvas

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
    canvas.clicks = new Array()
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
}
