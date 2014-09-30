

# Scalpel = tool for analyzing stabs 

window.scalpel = { 
  buttons : null, 
  bellCurve : null,

  attach : (here = null) -> # here = ID  
    return false unless here?
    preview.attach "##{here}"
    overlay.attach "##{here}", true
    unless scalpel.buttons? 
      scalpel.buttons = $('#pane-st-stabs-2').find('#scalpel-btns')[0]
      for b in $(scalpel.buttons).find('button')
        $(b).on 'click', scalpel.buttonClick 

    unless scalpel.bellCurve? 
      scalpel.bellCurve = d3.select('#n-stab-bell')
    return true

  detach : () ->
    alert 'Calling scalpel.detach()'
    preview.detach() 
    overlay.detach()
    return true

  load : (json) ->
    preview.loadJson json 
    scalpel.buttons.setAttribute 'marker', json.id 
    scalpel.comments.store json
    scalpel.comments.render()
    return true 

  buttonClick : (event) ->
    event.stopImmediatePropagation()
    id = $(this).attr 'id' 
    stbId = $(this).closest('#scalpel-btns').attr 'marker'

    switch id 
      when 'scalpel-quality'
        $.get "stab/bell-curve?id=#{stbId}"
      #when 'scalpel-rate'
      when 'scalpel-solution'
        active = $(this).hasClass 'active'
        if active 
          $(this).removeClass 'active'
          $.get "stab/load?id=#{stbId}"
        else
          $(this).addClass 'active'
          $.get "question/preview?id=#{stbId}&type=stb", (json) ->
            overlay.clear() 
            preview.loadJson json
      
    return true

  comments : { 
    list : new Array(), # list of objects = { x,y,tex, kgz_id }

    clear : () -> 
      scalpel.comments.list.length = 0 
      return true

    store : (json) ->
      scalpel.comments.clear() 
      return false unless json.kgz?

      for kgz in json.kgz
        for rmk in kgz.comments 
          a = new Object()
          a[j] = rmk[j] for j in ['x', 'y', 'tex']
          a.id = kgz.id 
          scalpel.comments.list.push a 
      return true 

    render : () ->
      overlay.clear() 
      active = $(preview.root).find('.item.active').children('img')[0]
      n=  parseInt active.getAttribute('kgz') #kgz-id
      return false unless n?

      # Cycle through the stored comments and render all that are for this particular kaagaz
      for rmk in scalpel.comments.list 
        continue if rmk.id isnt n
        overlay.add(rmk.tex, null, rmk.x, rmk.y)
      return true
  } 

  bell : { 
    render : (json) ->
      return false unless json.bell? # see json returned by stab/bell-curve

      $('#n-stab-bell').find('.orange').text json.rating

      width = 250 
      grpHeight = 40
      barHeight = 18

      scale = d3.scale.linear().domain([0,100]).range([0,width])
      # clear any old chart 
      scalpel.bellCurve.select('svg').remove()
      # provision for new one 
      svg = scalpel.bellCurve.select('#bell-curve')
            .append('svg')
            .attr('width', width)
            .attr('height', json.bell.length * grpHeight)

      bar = svg.selectAll('g')
               .data(json.bell)
               .enter()
               .append('g')
               .attr('transform', (d,i) -> "translate(0, #{i * grpHeight})")

      # draw the bars 
      bar.append('rect')
         .attr('width', (d) -> if d.p is 0 then 2 else scale(d.p) )
         .attr('height', 18)
         .style('fill', '#01537d')

      # render quality definition
      bar.append('text')
         .attr('y', 28) 
         .text( (d) -> d.tag )
         .style('fill', 'white')

      # render non-zero percentages 
      bar.append('text')
         .attr('y', (2*barHeight)/3 )
         .attr('x', (d) -> w = scale(d.p) ; if w > 20 then (w-30) else (w+5))
         .style('fill', 'white')
         .text( (d) -> if d.p then "#{d.p}%" else "" )
      return true 
  } 
} 
