
window.wsDeepdive = {
  students : (json) ->
    $('#graph-paper > svg').remove()
    w = 600
    h = 800

    nStudents = json.students.length
    textWidth = 150
    tipW = 10
    tipH = tipW/2
    sliderWidth = (nStudents * 18) - 50
    sliderWidth = if sliderWidth < 0 then 40 else sliderWidth

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

    # Add markers for DB-avg and teacher-avg benchmarks 
    sliders = svg.selectAll('g.benchmark').data(['t-avg', 'db-avg'])
    .enter()
    .append('g')
    .attr('class', (d,i) -> return "benchmark #{d}")
    .attr('transform', (d,i) ->
      ubound = if i is 0 then textWidth else (w - 100)
      return "translate(#{ubound + tipH}, 50) rotate(90)"
    )
    
    sliders.append('line')
    .attr('x1', tipH)
    .attr('x2', (nStudents * 18) - 50)
    .attr('y1', tipW / 2)
    .attr('y2', tipW / 2)
    .classed('slider', true)

    sliders.append('polygon')
    .attr('points', "0,0 #{tipW/2},#{tipH} 0,#{tipW}")
    .classed('tip', true)

    sliders.append('text')
    .text (d) ->
      return (if d is 't-avg' then "Your benchmark" else "DB-Avg")
    .classed('slider-text', true)
    .attr('x', sliderWidth/3)

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
      circle.transition().attr('cx', scaleX(x))
      empty = (score < 0)
      circle.classed('slider', !empty).classed('empty', empty)

    svg.select('g.t-avg')
    .transition()
    .attr('transform', "translate(#{scaleX(avg)}, 50) rotate(90)")

    svg.select('g.db-avg')
    .transition()
    .attr('transform', "translate(#{scaleX(dbAvg)}, 50) rotate(90)")

    return true
}
