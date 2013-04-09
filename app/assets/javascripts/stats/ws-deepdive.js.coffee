
window.wsDeepdive = {
  students : (json) ->
    target = $('#wide-chart-2')[0]
    $(target).empty()

    #$('#wide-chart-1 > svg').remove()
    w = 600
    h = 800

    nStudents = json.students.length
    textWidth = 150

    # <svg>
    svg = d3.select(target).append('svg')
    .attr('width', w)
    .attr('height', h)

    # Create one per row per student - as a <g> 
    
    # 1. List student names
    svg.selectAll('g').data(json.students)
    .enter()
    .append('g')
    .attr('marker', (d,i) -> return d.id)
    .attr('transform', (d,i) -> return "translate(0,#{80 + i*15})")
    .append('text')
    .text (d) ->
      return d.name

    # 2. Add the slider 
    scaleX = d3.scale.linear()
    scaleX.domain([0,6]).range([textWidth, w-100])

    svg.selectAll('g').data(json.students)
    .append('line')
    .attr('x1', textWidth)
    .attr('x2', w - 100)
    .attr('class', 'slider')
    .attr('transform', "translate(0,-5)")

    # Add the sliding circle
    svg.selectAll('g').data(json.students)
    .append('circle')
    .attr('r', 4)
    .attr('cy', -5)
    .attr('cx', (d,i) -> return scaleX(2))
    .attr('class', 'empty')

    # Add sliders 
    benchmarks = [
      {text: "Just the basics", value : 0},
      {text: "Your benchmark", value: 2.5},
      {text: "Avg. Difficulty", value: 3},
      {text: "Tough", value: 6}
    ]

    sliders = svg.selectAll('g.sliders')
    .data(benchmarks)
    .enter()
    .append('g')
    .attr('class', (d,i) ->
      switch i
        when 0,3 then return 'sliders'
        when 1 then return 'sliders t-avg'
        when 2 then return 'sliders db-avg'
    )
    .attr('transform', (d,i) ->
      return "translate(#{scaleX(d.value)},60)"
    )

    sliders.append('line')
    .attr('x1', 0)
    .attr('y1', (d,i) ->
      return (if i is 1 then -1 else -20)
    )
    .attr('x2', 0)
    .attr('y2', nStudents * 16)

    sliders.append('text')
    .attr('x', -5)
    .attr('y', (d,i) ->
      return (if i is 1 then -3 else -22)
    )
    .text (d) -> return d.text
    return true

  loadProficiencyData : (json) ->
    w = 600
    textWidth = 150
    avg = parseFloat json.benchmark
    dbAvg = parseFloat json.dbavg

    scaleX = d3.scale.linear()
    scaleX.domain([0,6]).range([textWidth, w-100]).clamp(true)

    # <svg>
    svg = d3.select('#wide-chart-2 > svg')

    for m,i in json.proficiency
      score = parseFloat(m.score) * avg
      x = if score is -1 then 0 else score

      circle = svg.select("g[marker='#{m.id}'] > circle")
      circle.transition().attr('cx', scaleX(x) - 5)
      empty = (score < 0)
      circle.classed('slider', !empty).classed('empty', empty)

    svg.select('g.t-avg')
    .transition()
    .attr('transform', "translate(#{scaleX(avg)}, 60)")

    svg.select('g.db-avg')
    .transition()
    .attr('transform', "translate(#{scaleX(dbAvg)}, 60)")

    return true

  byStudent : (json) ->
    target = $('#wide-chart-3')[0]
    $(target).empty()

    w = 600
    h = 800
    nTopics = json.proficiency.length
    textWidth = 10

    # <svg>
    svg = d3.select(target).append('svg')
    .attr('width', w)
    .attr('height', h)

    # x-scale
    scaleX = d3.scale.linear()
    scaleX.domain([0,6]).range([textWidth, w-100])

    # A seprate axis for non-example data 
    xAxis = d3.svg.axis()

    xAxis.scale(scaleX)
    .orient('bottom')
    .ticks(5)

    # Create one per row per topic 
    topics = svg.selectAll('g').data(json.proficiency)
    .enter()
    .append('g')
    .attr('transform', (d,i) ->
      vOffset = if i is 0 then 80 else 120
      return "translate(#{scaleX(0)},#{vOffset + i*45})"
    )

    axis = svg.select('g')
    
    ticks = axis.selectAll('g')
    .data([
      { text: "Bare basics (0)", j: 0 },
      { text: "Student proficiency", j: 1.5},
      { text: "Class average", j: 2.5 },
      { text: "Your benchmark", j: 3.5},
      { text: "Tough (6)", j: 6 } ])
    .enter()
    .append('g')
    .attr('transform', (d,i) ->
      return "translate(#{scaleX(d.j)}, -40)"
    )

    ticks.append('line')
    .attr('x1', 0)
    .attr('x2', 0)
    .attr('y1', 0)
    .attr('y2', 8)
    .classed('tick', true)

    ticks.append('text')
    .attr('y', (d,i) ->
      return (if i is 2 then 18 else -5)
    )
    .attr('x', (d,i) ->
      return (if i > 0 then -15 else 0)
    )
    .text (d) -> return d.text

    # Horizontal line thru the ticks
    axis.append('line')
    .attr('x1', textWidth)
    .attr('x2', w - 100)
    .attr('y1', -40)
    .attr('y2', -40)
    .classed('scale', true)

    # Topic names atop the individual bars
    topics.append('text')
    .attr('x', textWidth)
    .attr('y', -15)
    .text (d) -> return d.name

    # wide rectangles - light-blue - to show benchmark
    topics.append('rect')
    .classed('light', true)
    .attr('x', textWidth)
    .attr('y', -10)
    .attr('height', 20)
    .attr('width', (d,i) ->
      return scaleX(parseFloat(d.benchmark)) - textWidth
    )

    # narrow rectangles within wide rectangles to show student's proficiency
    topics.append('rect')
    .classed('blue', true)
    .attr('x', textWidth)
    .attr('y', -3)
    .attr('height', 6)
    .attr('width', (d,i) ->
      return scaleX(parseFloat(d.score) * parseFloat(d.benchmark)) - textWidth
    )

    # vertical tick to show historical average
    topics.append('line')
    .classed('black', true)
    .attr('y1', -7)
    .attr('y2', 7)
    .attr('x1', (d,i) ->
      return scaleX parseFloat(d.historical_avg)
    )
    .attr('x2', (d,i) ->
      return scaleX parseFloat(d.historical_avg)
    )

    svg.append('g')
    .classed('axis', true)
    .attr('transform', "translate(#{textWidth}, 115)")
    .call(xAxis)


    return true
}
