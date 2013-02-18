
window.wsDeepdive = {
  students : (json) ->
    $('#graph-paper > svg').remove()
    w = 600
    h = 800

    nStudents = json.students.length
    textWidth = 150

    # <svg>
    svg = d3.select('#graph-paper').append('svg')
    .attr('width', w)
    .attr('height', h)

    # Create one per row per student - as a <g> 
    
    # 1. List student names
    svg.selectAll('g').data(json.students)
    .enter()
    .append('g')
    .attr('marker', (d,i) -> return d.student.id)
    .attr('transform', (d,i) -> return "translate(0,#{80 + i*15})")
    .append('text')
    .text (d) ->
      return d.student.name

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
    svg = d3.select('#graph-paper > svg')

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
    $('#graph-paper > svg').remove()
    w = 600
    h = 800

    nTopics = json.proficiency.length
    textWidth = 150

    # <svg>
    svg = d3.select('#graph-paper').append('svg')
    .attr('width', w)
    .attr('height', h)

    # x-scale
    scaleX = d3.scale.linear()
    scaleX.domain([0,6]).range([textWidth, w-100])

    # Create one per row per topic 
    topics = svg.selectAll('g').data(json.proficiency)
    .enter()
    .append('g')
    .attr('transform', (d,i) -> return "translate(0,#{80 + i*15})")

    topics.append('text')
    .text (d) -> return d.name

    topics.append('line')
    .attr('x1', textWidth)
    .attr('x2', w - 100)
    .attr('class', 'slider')
    .attr('transform', "translate(0,-5)")

    topics.append('circle')
    .attr('r', 5)
    .attr('cy', -5)
    .attr('cx', (d,i) ->
      return scaleX(parseFloat(d.score) * parseFloat(d.avg))
    )
    .classed('slider', true)

    topics.append('line')
    .classed('benchmark', true).
    attr('x1', (d,i) ->
      return scaleX(parseFloat(d.avg))
    )
    .attr('x2', (d,i) ->
      return scaleX(parseFloat(d.avg))
    )
    .attr('y1', -15)
    .attr('y2', 3)

    return true
    
    
}
