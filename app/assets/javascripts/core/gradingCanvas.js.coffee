
window.gradingCanvas = {

  canvas: null,
  clicks: null,
  xoff: 0,
  yoff: 0,
  last:0,

  initialize: (id) ->
    gradingCanvas.canvas = if typeof id is 'string' then $(id) else id
    offset = gradingCanvas.canvas.offset()
    gradingCanvas.xoff = offset.left
    gradingCanvas.yoff = offset.top
    gradingCanvas.clear()

    return true
    

  # n: 0-indexed
  loadNth: (n, list = '#ungraded-responses', canvas = '#grading-canvas') ->
    list = $(list).find('ul:first')
    nImages = list.children('li').length
    return if nImages < 1
    
    n %= nImages
    canvas = if typeof canvas is 'string' then $(canvas) else canvas
    
    ctx = canvas[0].getContext('2d')
    image = new Image()
    src = list.children('li').eq(n).text()
    image.onload = () ->
      ctx.drawImage(image,15,0)
      ctx.strokeStyle="#fd9105"
      ctx.lineJoin="round"
    image.src = "#{gutenberg.server}/locker/#{src}"

  record: (event) ->
    x = event.pageX - gradingCanvas.xoff
    y = event.pageY- gradingCanvas.yoff

    return if x < 0 || y < 0

    last = gradingCanvas.last
    gradingCanvas.clicks[last] = [x,y]
    gradingCanvas.last += 1

    if (last % 2) is 1
      first = gradingCanvas.clicks[last-1]
      second = gradingCanvas.clicks[last]

      if first[0] > second[0]
        a = second[0]
        width = first[0]-second[0]
      else
        a = first[0]
        width = second[0] - first[0]

      if first[1] > second[1]
        b = second[1]
        height = first[1]-second[1]
      else
        b = first[1]
        height = second[1] - first[1]

      #alert "#{width} --> #{height}"

      ctx = gradingCanvas.canvas[0].getContext('2d')
      ctx.strokeRect a,b,width,height
    return true
    
  clear: () ->
    gradingCanvas.clicks = new Array()
    gradingCanvas.last = 0
}
