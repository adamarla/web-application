
start_date = null
getDate = (offset) ->
    y = parseInt(start_date.substr(0, 4))
    mm = parseInt(start_date.substr(5, 2))-1
    dd = parseInt(start_date.substr(8,2))
    thisDate = new Date(y, mm, dd)
    thisDate.setDate(thisDate.getDate() + offset)
    dd = thisDate.getDate()
    mm = thisDate.getMonth()+1
    y = thisDate.getFullYear()
    dd + '/' + mm

window.usageReport = {

  byWeek: (json, target) ->
    chart = target
    data = json.data
    
    barWidth = 75 
    margin = { top: 50, right: 0, bottom: 50, left: 40}
    width = (barWidth * data.length) - margin.left - margin.right
    height = 500 - margin.top - margin.bottom

    x = d3.scale.ordinal().rangeRoundBands([0, width], 0.1)
    y = d3.scale.linear().range([height, 0])

    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left").ticks(10, "")

    target.empty()
    chart = target[0]
    svg = d3.select(chart).append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(#{margin.left}, #{margin.top})")

    x.domain(data.map((d) -> d.name ))
    y.domain([0, d3.max(data, (d) -> d.num_attempts)])

    svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0, #{height})")
    .call(xAxis)

    svg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 6)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("Attempts")
    .attr("class", "black-labels")

    svg.selectAll(".bar")
    .data(data)
    .enter().append("rect")
    .attr("class", "bar")
    .attr("x", (d) -> x(d.name))
    .attr("width", x.rangeBand())
    .attr("y", (d) -> y(d.num_attempts))
    .attr("height", (d) -> height - y(d.num_attempts))

    return true
 
  byUser: (json, target) ->

    start_date = json.date
    data = json.data

    margin = { top: 50, right: 0, bottom: 50, left: 140 }
    gridSize = 15 
    width = gridSize * data[0].counts.length - margin.left - margin.right
    height = gridSize * data.length
    buckets = 9
    colors = ["#ffffd9","#edf8b1","#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8","#253494","#081d58"]
    times = []
    legendElementWidth = gridSize * 2

    # max tries for any student reqd to set color range
    maxes = 0
    data.forEach((valueObj, i) ->
      maxes[i] = valueObj.counts)

    colorScale = d3.scale.quantile().domain([0, buckets-1, d3.max(maxes)]).range(colors)

    target.empty()
    
    target.append("<div id='names' class='span2'/>")
    names = target.find("#names")
    names.empty()
    svgN = d3.select(names[0]).append('svg')
    .attr('width', margin.left)
    .attr('height', height + margin.top)
    .append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

    nameLabels = svgN.selectAll(".nameLabel")
    .data(data)
    .enter().append("text")
    .text((d) -> return d.name)
    .attr("x", 0)
    .attr("y", (d, i) -> i * gridSize )
    .style("text-anchor", "end")
    .attr("transform", "translate(0, #{gridSize / 1.5})")
    .attr("class", "black-labels")
    .append("title").text((d) -> "#{d.attempts} problems @ #{d.avg_time} min/problem")

    target.append("<div id='heat' class='span10'/>")
    heat = target.find("#heat")
    heat.empty()
    svgH = d3.select(heat[0]).append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top)
    .append('g')
    .attr('transform', "translate(0, #{margin.top})")

    dateLabels = svgH.selectAll(".dateLabel")
    .data(data[0].counts)
    .enter().append("text")
    .text((d, i) -> getDate(i))
    .attr("y", 0)
    .style("text-anchor", "start")
    .attr("transform", (d, i) -> "translate(#{gridSize * i + 8}, -10) rotate(-75)")
    .attr("class", "black-labels")

    heatMap = svgH.selectAll(".hour")
    .data(data)
    .enter().append("g")
    .attr("transform", (d, i) -> "translate(0, #{i * gridSize})")
    .selectAll("rect")
    .data((d) -> d.counts)
    .enter().append("rect")
    .attr("x", (d, i) -> i * gridSize)
    .attr("rx", 4)
    .attr("ry", 4)
    .attr("class", "hour bordered")
    .attr("width", gridSize)
    .attr("height", gridSize)
    .style("fill", colors[0])
    
    heatMap.transition().duration(3000).style("fill", (d) -> colorScale(d))
    heatMap.append("title").text((d) -> d )

    return true
}

