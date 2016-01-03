
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
  
  byUser: (json, target) ->

    start_date = json.date
    data = json.data

    margin = { top: 50, right: 0, bottom: 50, left: 140 }
    gridSize = 20 
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
    
    names = target.find("#names")
    names.empty()
    svgN = d3.select(names[0]).append('svg')
    .attr('width', margin.left)
    .attr('height', height + margin.top)
    .append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

    dayLabels = svgN.selectAll(".dayLabel")
    .data(data)
    .enter().append("text")
    .text((d) -> return d.name)
    .attr("x", 0)
    .attr("y", (d, i) -> i * gridSize )
    .style("text-anchor", "end")
    .attr("transform", "translate(0, #{gridSize / 1.5})")
    .attr("class", "black-labels")

    heat = target.find("#heat")
    heat.empty()
    svgH = d3.select(heat[0]).append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top)
    .append('g')
    .attr('transform', "translate(0, #{margin.top})")

    timeLabels = svgH.selectAll(".timeLabel")
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

