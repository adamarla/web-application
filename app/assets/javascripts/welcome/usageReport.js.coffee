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

  byBucket: (json, target) ->
    target.empty()
    chart = target[0]
    data = json.data
    # buckets - 1, 2-5, 6-10, 11-20, 21-30, 31-50, 50+
    buckets = [[], [], [], [], [], [], []]
    margin = { top: 50, right: 50, bottom: 50, left: 50 }
    width = 80 * buckets.length - margin.left - margin.right
    height = 400

    x = d3.scale.ordinal().rangeRoundBands([0, width], 0.1)
    y0 = d3.scale.linear().range([height, 0])
    y1 = d3.scale.linear().range([height, 0])

    xAxis = d3.svg.axis().scale(x).orient("bottom")
    y0Axis = d3.svg.axis().scale(y0).orient("left")
    y1Axis = d3.svg.axis().scale(y1).orient("right")

    svg = d3.select(chart).append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(#{margin.left}, #{margin.top})")

    zeros = 0
    data.forEach((u, i) ->
      n = u.ns + u.nq
      t = u.ts + u.tq + u.tt
      nt = {"n": n, "t": t, "d": u.da, "s": u.sp}
      switch true
        when n == 1 then buckets[0].push nt
        when n in [2..5] then buckets[1].push nt
        when n in [6..10] then buckets[2].push nt
        when n in [11..20] then buckets[3].push nt
        when n in [21..30] then buckets[4].push nt
        when n in [31..50] then buckets[5].push nt
        when n > 50 then buckets[6].push nt
        else zeros++)

    names = ["1", "2-5", "6-10", "11-20", "21-30", "31-50", " > 50"]
    x.domain(names)
    y0.domain([0, d3.max(buckets, (d) -> d.length)])
    y1.domain([0, d3.max(buckets,
      (d) ->
        t_domain = d3.mean(d, (d) -> d.t)/60
        n_domain = d3.mean(d, (d) -> d.n)
        if t_domain > n_domain then t_domain else n_domain
    )])

    svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0, #{height})")
    .call(xAxis)
    .append("text")
    .attr("x", width + 20)
    .attr("y", 20)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("Num tries (range)")

    svg.append("g")
    .attr("class", "y axis")
    .call(y0Axis)
    .append("text")
    .attr("x", 0)
    .attr("y", -30)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .style("fill",  "#98abc5")
    .text("Users")

    y1g = svg.append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(#{width}, 0)")
    .call(y1Axis)

    y1g.append("text")
    .attr("x", 0)
    .attr("y", -30)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .style("fill",  "#9acd32")
    .text("Avg. time on app (per User in mins)")

    y1g.append("text")
    .attr("x", 0)
    .attr("y", -20)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .style("fill",  "#ef2211")
    .text("Avg. num tries (per User)")

    bucket = svg.selectAll("bucket")
    .data(buckets)
    .enter().append("g")
    .attr("class", "bucket")
    .attr("transform", (d, i) -> "translate(#{x(names[i])})")
    
    bkt = bucket.selectAll("rect").data((d) -> [d]).enter()

    bkt.append("rect")
    .attr("class", "bar")
    .attr("x", 0)
    .attr("width", x.rangeBand()/3)
    .attr("y", (d) -> y0(d.length))
    .attr("height", (d) -> height - y0(d.length))
    .style("fill",  "#98abc5")
    .append("title").text((d) -> "#{d.length} users")

    bkt.append("rect")
    .attr("class", "bar")
    .attr("x", x.rangeBand()/3)
    .attr("width", x.rangeBand()/3)
    .attr("y", (d) -> y1(d3.mean(d, (d) -> d.n)))
    .attr("height", (d) -> height - y1(d3.mean(d, (d) -> d.n)))
    .style("fill",  "#ef2211")
    .append("title").text((d) -> "#{Math.round(d3.mean(d, (d) -> d.n))} tries")

    bkt.append("rect")
    .attr("class", "bar")
    .attr("x", 2*x.rangeBand()/3)
    .attr("width", x.rangeBand()/3)
    .attr("y", (d) -> y1(d3.mean(d, (d) -> d.t)/60))
    .attr("height", (d) -> height - y1(d3.mean(d, (d) -> d.t)/60))
    .style("fill",  "#9acd32")
    .append("title").text((d) -> "#{Math.round(d3.mean(d, (d) -> d.t)/60)} mins")

    return true

  byWtp: (json, target) ->

    target.empty()
    chart = target[0]

    byPrice = {}
    for u in json
      byPrice[u.pr] = [] unless (u.pr of byPrice)
      byPrice[u.pr].push u

    data = []
    pricePoints = []
    for k in Object.keys(byPrice).sort()
      vals = byPrice[k]
      ag = na = nr = 0
      for v in vals
        if v.ag then ag=ag+1 else na=na+1
        if v.ag then nr=nr+v.nr
      data.push ag
      data.push na
      data.push (nr/ag).toFixed(2)
      pricePoints.push k

    thickness = 20
    gap = 20
    width = 350
    height = pricePoints.length*(3*thickness + gap)

    # specify chart area and dimensions
    chart = d3.select(chart).append("svg")
      .attr("width", 175 + width + 175)
      .attr("height", height)

    color = d3.scale.category20()

    # legend
    keys = ["Agreed to Pay", "Didn't Agree", "Avg. #times asked (before agreeing)"]
    legend = chart.selectAll(".legend")
      .data(keys)
      .enter()
      .append("g")
      .attr("transform", (d, i) -> "translate(#{i*120+20}, 0)")

    legend.append("rect")
      .attr("width", 18)
      .attr("height", 18)
      .attr("class", "bar")
      .style("fill", (d, i) -> color(i))
      .style("stroke", (d, i) -> color(i))

    legend.append("text")
      .attr("class", "legend")
      .attr("x", 18+4)
      .attr("y", 18-4)
      .text((d) -> d)

    x = d3.scale.linear().range([0, width]).domain([0, d3.max(data)])
    y = d3.scale.linear().range([height + gap, 0])

    yAxis = d3.svg.axis().scale(y).tickFormat(' ').tickSize(0).orient("left")

    # create bars
    bar = chart.selectAll("g")
      .data(data)
      .enter().append("g")
      .attr("transform", (d, i) -> "translate(100, #{i*thickness+(gap*(0.5+Math.floor(i/3)))})")

    # create rectangles of correct width
    bar.append("rect")
      .style("fill", (d, i) -> "#{color(i%3)}")
      .attr("class", "bar")
      .attr("width", x)
      .attr("height", thickness-1)

    # add text label in bar
    bar.append("text")
      .attr("x", (d) -> if (d > 1) then x(d) - 15 else x(d))
      .attr("y", thickness/2)
      .attr("fill", "red")
      .attr("dy", ".40em")
      .text((d) -> d)

    # draw labels
    bar.append("text")
      .attr("class", "label")
      .attr("x", (d) -> -20)
      .attr("y", thickness*3/2)
      .text((d, i) -> if (i%3 == 0) then "Rs.#{pricePoints[Math.floor(i/3)]}" else "")

    chart.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(100, #{gap})")
      .call(yAxis)

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
    y0Axis = d3.svg.axis().scale(y).orient("left")
    y1Axis = d3.svg.axis().scale(y).orient("right")

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

