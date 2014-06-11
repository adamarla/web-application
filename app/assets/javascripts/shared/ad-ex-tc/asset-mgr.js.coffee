
# Passed 'json' is assumed to have the following - and only the following - keys 
#    type: [ quizzes | lessons  | criteria ]
#    used : list of used assets of type = 'type'
#    available : the other unused / available assets of type = 'type'
#    id : of the course/rubric being edited

window.assetMgr = {
  root : {
    used : null,
    available : null
  }

  reset : (json, update = false) ->
    for m in ['used', 'available']
      nd = if update then assetMgr.root[m] else $("##{json.type}-#{m}")[0] 
      # --> $('#lessons-used') or $('#quizzes-available') etc.
      assetMgr.root[m] = nd unless update 

      if nd? 
        for ul in $(nd).children('ul')
          $(ul).sortable 'destroy'
          $(ul).empty() unless update

    unless update 
      nd = assetMgr.root['used'] 
      btns = $(nd).closest('.tab-pane').find('button')
      for b in btns 
        b.setAttribute 'data-id', json.id 
        b.setAttribute 'data-type', json.type 
    return true

  render : (json, update = false) ->
    return false if not (json.used? and json.available?)
    assetMgr.reset(json, update)

    for j in ['used', 'available']
      root = assetMgr.root[j]
      continue unless root? 

      ul = $(root).children('ul')
      singleColumn = ul.length is 1  

      for d,index in json[j]
        nd = if singleColumn then ul[0] else ul[index % 2]
        if json.type isnt 'criteria'
          html = "<li data-id=#{d.id}>#{d.name}</li>"
          $(html).appendTo $(nd)
        else
          li = $("<li data-id=#{d.id}></li>")
          li = if update then li.prependTo($(nd)) else li.appendTo($(nd))
          html = criteria.render d
          $(html).appendTo $(li)

      for l in ul
        $(ul).sortable { group: json.type } 
    return true
}

jQuery ->
  $('#pane-course-lessons, #pane-course-quizzes').on 'click', 'button', ->
    id = this.getAttribute 'data-id'
    type = this.getAttribute 'data-type'
    nd = assetMgr.root['used']
    ret = { used: new Array(), id: id, type: type }
    if nd?
      ul = $(nd).children('ul').eq(0)
      for li in ul.children('li')
        x = li.getAttribute('data-id')
        ret.used.push x

    spinner.setText 'Updating ...'
    $.post 'course/update', ret
    return true

