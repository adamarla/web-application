
# Passed 'json' is assumed to have the following - and only the following - keys 
#    type: [ quizzes | lessons ]
#    used : list of used assets of type = 'type'
#    available : the other unused / available assets of type = 'type'
#    id : of the course being edited

window.assetMgr = {
  root : {
    used : null,
    available : null
  }

  reset : (json) ->
    for m in ['used', 'available']
      nd = $("##{json.type}-#{m}")[0]  # --> $('#lessons-used') or $('#quizzes-available') etc.
      assetMgr.root[m] = nd 

      if nd? 
        for ul in $(nd).children('ul')
          $(ul).sortable 'destroy'
          $(ul).empty()

    # Set data-id attribute on the submit button 
    for m in ['used', 'available']
      nd = assetMgr.root[m]
      button = $(nd).closest('.tab-pane').find('button')[0]
      if button? 
        button.setAttribute 'data-id', json.id 
        break
    return true

  render : (json) ->
    return false if not (json.used? and json.available?)
    assetMgr.reset(json)

    for j in ['used', 'available']
      root = assetMgr.root[j]
      continue unless root? 

      singleColumn = j is 'used'
      ul = $(root).children('ul')

      for d,index in json[j]
        nd = if singleColumn then ul[0] else ul[index % 2]
        html = "<li data-id=#{d.id}>#{d.name}</li>"
        $(html).appendTo $(nd)

      for l in ul
        $(ul).sortable { group: json.type } 
    return true
}
