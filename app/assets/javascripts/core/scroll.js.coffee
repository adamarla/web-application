
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
    having : {
      check : 1,
      radio : 2,
      link : 4,
      select : 8,
      button : 16,
      nolabel : 32
    }
    

    ###
      'initialize' creates just the accordion headers. This next method 
      fills up the next <div> - which is for the content - with data corresponding
      to the just clicked accordion header

      This method therefore assumes the following for json[key]:
        {name: ..., id: ..., parent: ...} where json itself is an array
    ###

    loadJson: (json, key, here, ticker = null, render = scroll.having.check) ->
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

        show = { radio:false, checkbox:false, select:false, button:false, link:false, label:true }
        e = ['checkbox', 'radio', 'link', 'select', 'button', 'label'] # must stay in sync with scroll.having

        for element, k in e
          show[element] = not show[element] if (render & (1 << k))

        item = swissKnife.forge m, key, show
        swissKnife.editAnchor(item, n) if show['link']

        if ticker?
          v = n[ticker]
          t = item.children('.micro-ticker').eq(0)
          t.text v if t?
        item.appendTo content

      for m in here.children '.scroll-content'
        scroll.columnize $(m)
      return true

    overlayJson: (json, key, here, onto) ->
      # Unlike loadJson, this method does NOT change the HTML. It only loads the 
      # passed JSON onto whatever is already present. Moreover, this method is limited
      # to only checking/unchecking radio buttons and check boxes

      # The passed JSON is of the form: [.. {key: {parent: .., id:[ .. ]} ... ]
      # Its understood that 'parent' is the marker on the scroll-heading and id's are 
      # the markers on whatever is specified with 'onto'

      return if not onto?
      here = if typeof here is 'string' then $(here) else here

      # Step 1: Uncheck all checkboxes and/or radio buttons within 'here'
      for m in here.find "input[type='checkbox'],input[type='radio']"
        $(m).prop 'checked', false

      # Step 2: Check the checkboxes/radio-buttons as specified in the passed JSON
      for m in json
        item = m[key]
        parent_id = item.parent
        ids = item.id # an array

        header = here.find(".scroll-heading[marker=#{parent_id}]").eq(0)
        continue if header.length is 0

        content = header.next()

        # This method expects an array of IDs. So, if its a single ID, then create 
        # a 1-element array from it before proceeding 
        if not (ids instanceof Array)
          ids = ["#{ids}"]

        for j in ids
          target = content.find("#{onto}[marker=#{j}]").eq(0)
          continue if target.length is 0

          for k in target.children("input[type='checkbox'], input[type='radio']")
            $(k).prop 'checked', true

      return true

    columnize: (content) ->
      ###
        Let 'loadJson' be the only method that calls this one
        Rearranges already placed data in scroll-content into N columns - where N 
        is gotten from the 'columns' attribute on scroll-content
      ###
      content = if typeof content is 'string' then $(content) else content
      return if not content.hasClass 'scroll-content'

      nColumns = content.attr 'columns'
      nColumns = if not nColumns? then 1 else parseInt(nColumns)
      return true if nColumns < 2

      for j in [1..nColumns]
        $("<div class='one_#{nColumns} column'></div>").appendTo content

      items = content.children().not('.column')
      columns = content.children '.column'
      j = 0 # starting column index

      for m in items
        j = if j is nColumns then 0 else j
        c = columns.eq(j)
        $(m).detach().appendTo c
        j += 1

      return true

      
  }

