

window.assetMgr = {
  root : {
    used : null,
    available : null
  }

  reset : () ->
    for m in ['used', 'available']
      nd = assetMgr.root[m]
      if nd? 
        for ul in $(nd).children('ul')
          $(ul).sortable 'destroy'
          $(ul).empty()
      assetMgr.root[m] = null
    return true

  render : (json) ->
    # Passed 'json' is assumed to have the following - and only the following - keys 
    #    type: [ quizzes | lessons ]
    #    used : list of used assets of type = 'type'
    #    available : the other unused / available assets of type = 'type'

    return false if not (json.used? and json.available?)
    assetMgr.reset()

    for j in ['used', 'available']
      assetMgr.root[j] = $("##{json.type}-#{j}")[0] # Eg: $('#lessons-used'), $('#quizzes-available')
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
