
###
  'plot' assumes that the passed JSON has atleast the following two keys 
  within json[key] - 'x' and 'y' and that the values for these are numbers (not strings)

  'consider' is a short call back function that looks at an individual JSON record
  and reports whether the record should be considered for plotting. The condition is 
  defined by us 
###


window.graph = {
  x: null,
  y:null,
  labels: null, # x,y and labels are arrays. And (x[i],y[i],label[i]) ALWAYS go together
  initialized: false,

  initialize: () ->
    if graph.initialized
      graph.clear()
    else
      graph.x = new Array()
      graph.y = new Array()
      graph.labels = new Array()
      graph.initialized = true
    return true

  loadJson: (json, key, label = null, pick = null, using = null) ->
    nElements = json.length
    for d in json
      e = d[key]
      if pick? && using?
        continue if pick(e, using) is false
      graph.x.push e.x
      graph.y.push(nElements - e.y)
      graph.labels.push e[label] if label?
    return true

  clear: () ->
    graph.x.length = 0 if graph.x.length?
    graph.y.length = 0 if graph.y.length?
    graph.labels.length = 0 if graph.labels.length?
    return true

  collate: (correction = [], singlePt = true) ->
    xCorrection = if correction[0]? then correction[0] else 0
    yCorrection = if correction[1]? then correction[1] else 0

    ret = []

    for x, index in graph.x
      xbar = x - xCorrection
      ybar = graph.y[index] - yCorrection

      if singlePt
        ret.push [xbar, ybar]
      else
        ret.push [xbar, ybar], [0, ybar], null # null to form individual line segments
    return ret
    
  filter: {
    notZero: (record, field) ->
      if record[field] is 0 then return false else return true
  }

  draw: (correction = [], singlePt = true) ->
    pts = graph.collate correction, singlePt
    p = $.plot $('#flot-chart'), [
      {
        data: pts,
        lines: {show: !singlePt},
        points: {show: true, radius: 4}
      }
    ],
    {
      yaxis: { tickLength: 0 },
      grid: {
        borderWidth: 0,
        aboveData: false
      }
    }
    # Now set the names of students as labels on the extremity point
    # Ref: http://stackoverflow.com/questions/1174298/flot-data-labels

    skip = if singlePt then 1 else 3
    renderedPts = p.getData()[0].data
    placeholder = p.getPlaceholder()

    for pt, index in renderedPts by skip
      ###
        When singlePt is false, then for each label, there are 3 elements in 
        'renderedPts' - [(x1,y1), (x2, y2), null]
      ###
      id = index / skip
      label = graph.labels[id]
      rendered = p.pointOffset { x: pt[0], y: pt[1] }
      $("<div class='data-point-label'>#{label}</div>").css({
        top: rendered.top - 20,
        left: rendered.left + 5
      }).appendTo(placeholder).fadeIn('slow')
    return true
}
