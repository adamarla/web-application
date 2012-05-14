
jQuery ->
  window.scroll = {
    initialize: (json, key, here) ->
      return if not key?
      here = if typeof here is 'string' then $(here) else here
      ###
        Method assumes that json[key] is of the form {name:XYZ, id:MNO}.
        'json' itself is an array hashes with primary key = key 
      ###
      here.empty()
      for m,j in json
        n = m[key]
        $("<div class='scroll-heading' marker=#{n.id}>#{n.name}</div>").appendTo here
        $("<div class='scroll-content'></div>").appendTo here
      return true

    ###
      'initialize' creates just the accordion headers. This next method 
      fills up the next <div> - which is for the content - with data corresponding
      to the just clicked accordion header

      This method therefore assumes the following for json[key]:
        {name: ..., id: ..., parent: ...} where json itself is an array
    ###
    loadJson: (json, key, here) ->
      return if not key?
      here = if typeof here is 'string' then $(here) else here

      for m,j in json
        n = m[key]
        parent= n.parent
        continue if not parent?
        # First, find the accordion heading within which to append the new data
        header = here.children(".scroll-heading[marker=#{parent}]").eq(0)
        continue if header.length is 0

        content = header.next() # the immediately following element has to be the content
        continue if content.length is 0

        item = swissKnife.forge m, key, {checkbox:true}
        item.appendTo content
      return true
      
  }

