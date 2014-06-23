
window.wsSummary = (json) ->
  target = $('#wide-chart-1')[0]
  $(target).empty()

  w = 600
  h = 800

  nStudents = json.totals.length
  nQues = json.questions.length
  quizTotal = parseInt json.max

  # <svg>
  svg = d3.select(target).append('svg')
  .attr('width', w)
  .attr('height', h)

  svg.selectAll('g').data(json.root)
  .enter()
  .append('g')
  .attr('transform', (d,i) -> return "translate(0,#{80 + i*15})")

  # little squares 
  littleSqOffset = 120

  svg.selectAll('g').selectAll('rect')
  .data(json.questions)
  .enter()
  .append('rect')
  .attr('x', (d,i) -> return littleSqOffset + 12*i )
  .attr('width', 11)
  .attr('height',11)
  .attr('y',-7)
  .classed('cell', true)

  # Question labels atop the squares 
  svg.selectAll('g.labels').data(json.questions)
  .enter()
  .append('g')
  .attr('transform', (d,i) -> return "translate(#{littleSqOffset + 10 + i*12},65) rotate(-90)")
  .append('text')
  .attr('class', 'labels')
  .text (d) ->
    return d.name

  # student names - extreme left
  svg.selectAll('g').data(json.root)
  .append('text')
  .attr('y', 2)
  .text (d) ->
    return d.name

  # color code the little squares
  svg.selectAll('g').data(json.root)
  .selectAll('rect')
  .data((d,i) -> return d.spectrum)
  .attr('class', (d,i) -> return d)

  # bar-chart to show total scores
  barchartOffset = littleSqOffset + (nQues * 12) + 10
  scaleX = d3.scale.linear().domain([0, quizTotal]).range([0,100])
  unitX = scaleX(1)
  unitY = 15

  svg.selectAll('g').data(json.totals)
  .append('rect')
  .attr('class', 'bar')
  .attr('x', barchartOffset)
  .attr('y', -7)
  .attr('height', 11)
  .attr('width', (d,i) ->
    marks = parseFloat d
    return (if marks > 0 then scaleX(marks) else 2)
  )

  svg.selectAll('g').data(json.totals)
  .append('text')
  .text (d) ->
    marks = parseFloat d
    return (if marks is -1 then "" else marks)
  .attr('x', (d,i) ->
    marks = parseFloat d
    return (if marks > -1 then (barchartOffset + scaleX(marks) + 5) else barchartOffset)
  ).attr('y',2)
  .attr('class', 'bar-text')

  return true
