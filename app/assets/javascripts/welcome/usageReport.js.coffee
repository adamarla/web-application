
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

getIntensity = (time, num_attempts) ->
  time/num_attempts > 1800 ? 4 : (time/num_attempts) * 2

getBucketDivisions = (counts, idx) ->
  if idx == 0
    [(counts.filter (c) -> c == 1), (counts.filter (c) -> c == 2), (counts.filter (c) -> c == 3)] 
  else if idx == 1
    [(counts.filter (c) -> c == 4), (counts.filter (c) -> c in [5..7]), (counts.filter (c) -> c in [8..10])] 
  else if idx == 2
    [(counts.filter (c) -> c in [11..15]), (counts.filter (c) -> c in [16..20])] 
  else if idx == 3
    [(counts.filter (c) -> c in [21..25]), (counts.filter (c) -> c in [26..30])] 
  else if idx == 4
    [(counts.filter (c) -> c in [31..40]), (counts.filter (c) -> c in [41..50])] 
  else 
    counts

window.usageReport = {

  byBucket: (json, target) ->
    target.empty()
    chart = target[0]
    data = json.data
    # buckets - 1, 2-5, 6-10, 11-20, 21-30, 31-50, 50+
    buckets = [[], [], [], [], [], [], []]

    margin = { top: 50, right: 50, bottom: 50, left: 140 }
    width = 80 * buckets.length - margin.left - margin.right
    height = 400

    x = d3.scale.ordinal().rangeRoundBands([0, width], 0.1)
    y = d3.scale.linear().range([height, 0])

    xAxis = d3.svg.axis().scale(x).orient("bottom")
    yAxis = d3.svg.axis().scale(y).orient("left")

    svg = d3.select(chart).append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(#{margin.left}, #{margin.top})")

    zeros = 0
    data.forEach((u, i) ->
      v = u.ns + u.nq
      switch true
        when v == 1 then buckets[0].push v
        when v in [2..5] then buckets[1].push v
        when v in [6..10] then buckets[2].push v
        when v in [11..20] then buckets[3].push v
        when v in [21..30] then buckets[4].push v
        when v in [31..50] then buckets[5].push v
        when v > 50 then buckets[6].push v 
        else zeros++)

    names = ["1", "2-5", "6-10", "11-20", "21-30", "31-50", " > 50"]
    x.domain(names)
    y.domain([0, d3.max(buckets, (d) -> d.length)])

    svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0, #{height})")
    .call(xAxis)
    .append("text")
    .attr("x", width + 40)
    .attr("y", 10)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("Attempts")

    svg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
    .append("text")
    .attr("x", 0)
    .attr("y", -20)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("Users")

    bucket = svg.selectAll(".bucket")
    .data(buckets)
    .enter().append("g")
    .attr("class", "bucket")
    .attr("transform", (d, i) -> "translate(#{x(names[i])})")

    bucket.selectAll("rect")
    .data((d) -> [d.length]) 
    .enter().append("rect")
    .attr("class", "bar")
    .attr("x", 0)
    .attr("width", x.rangeBand())
    .attr("y", (d) -> y(d))
    .attr("height", (d) -> height - y(d))
    .style("fill",  "#98abc5")
    .append("title").text((d) -> d)

    return true

  byUser: (json, target) ->
    chart = target
    data = json.data

    maxAttempts = d3.max(data.num_attempts, (d) -> d)
    maxDaysActive = d3.max(data.days_active, (d) -> d)

    dayWidth = 5 
    margin = { top: 50, right: 0, bottom: 50, left: 40}
    width = (dayWidth * maxDaysActive) - margin.left - margin.right
    height = (dayWidth * maxAttempts) - margin.top - margin.bottom

    x = d3.scale.linear().range(0, [width])
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

    data.num_attempts.forEach((v, i) ->
      svg.append("line")
      .attr("x1", 0).attr("y1", maxAttempts - data.num_attempts[i])
      .attr("x2", data.days_active[i] * dayWidth).attr("y2", maxAttempts - data.num_attempts[i])
      .attr("stroke-width", 2)
      .attr("stroke-dasharray", Math.floor(data.days_between_attempts[i]), 1))

    return true

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
    yAxis = d3.svg.axis().scale(y).orient("left")

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
    .text("Users | Attempts")
    .attr("class", "black-labels")

    week = svg.selectAll(".week")
    .data(data)
    .enter().append("g")
    .attr("class", "week")
    .attr("transform", (d) -> "translate(#{x(d.name)})")
 
    week.selectAll("rect")
    .data((d) -> [d.unique_users, d.num_attempts])
    .enter().append("rect")
    .attr("class", "bar")
    .attr("x", (d, i) -> if i == 0 then 0 else x.rangeBand()/2)
    .attr("width", x.rangeBand()/2)
    .attr("y", (d) -> y(d))
    .attr("height", (d) -> height - y(d))
    .style("fill", (d, i) -> if i == 0 then "#98abc5" else "#8a89a6")
    .append("title").text((d) -> d)

    return true
 
  byDay: (json, target) ->

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

