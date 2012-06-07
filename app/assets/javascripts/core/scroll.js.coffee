
jQuery ->
  window.scroll = {

    options : {
      header:'.scroll-heading',
      collapsible:true,
      active:false,
      fillSpace:true,
      icons: {'header': 'ui-icon-circle-plus', 'headerSelected':'ui-icon-circle-minus'}
    }

    initialize: (json, key, here) ->
      return if not key?
      here = if typeof here is 'string' then $(here) else here
      ###
        Method assumes that json[key] is of the form {name:XYZ, id:MNO}.
        'json' itself is an array hashes with primary key = key 
      ###

      here.empty()
      here.accordion('destroy')
      # Imp: destroy any previously attached accordion object and re-create it
      # in the new run. Otherwise, one would see different behaviour in each run
      
      for m,j in json
        n = m[key]
        $("<div class='scroll-heading' marker=#{n.id}>#{n.name}</div>").appendTo here
        $("<div class='scroll-content'></div>").appendTo here
      return true

    # Enum to specify how passed JSON should be rendered by the 'loadJson' method
    as : {
      itemWithCheck : 1,
      itemWithRadio : 2,
      anchor : 3,
      itemWithSelect: 4
    }

    ###
      'initialize' creates just the accordion headers. This next method 
      fills up the next <div> - which is for the content - with data corresponding
      to the just clicked accordion header

      This method therefore assumes the following for json[key]:
        {name: ..., id: ..., parent: ...} where json itself is an array
    ###

    loadJson: (json, key, here, ticker = null, render = scroll.as.itemWithCheck) ->
      return if not key?
      here = if typeof here is 'string' then $(here) else here

      for m,j in json
        n = m[key]
        parent = n.parent
        continue if not parent?
        parentId = n.parent_id # part of JSON returned by quiz/testpapers

        # First, find the accordion heading within which to append the new data
        header = here.children(".scroll-heading[marker=#{parent}]").eq(0)
        continue if header.length is 0

        content = header.next() # the immediately following element has to be the content
        continue if content.length is 0

        switch render
          when scroll.as.itemWithCheck then item = swissKnife.forge m, key, {checkbox:true}
          when scroll.as.itemWithRadio then item = swissKnife.forge m, key, {radio:true}
          when scroll.as.itemWithSelect then item = swissKnife.forge m, key, {select:true}
          when scroll.as.anchor then item = $("<a href='#' marker=#{n.id} parent=#{n.parent} p_id=#{parentId}>#{n.name}</a>")
        if ticker?
          v = n[ticker]
          t = item.children().eq(3)
          t.text v

        item.appendTo content
      return true
      
  }

