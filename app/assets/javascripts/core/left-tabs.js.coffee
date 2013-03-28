

###
  For when .tabbable.tab-left need to be created on the fly based on returned JSON

  JSON below has the following * fixed * form 
    {tabs : [{name : xyz, id : 123}, {name : abc, id : 789} .... ]}
  Only this kind of JSON will result in tabs

  Optionally, there can also be a key called :filters
    { tabs: [{ ... }, { ... } ... ], filters : [a,b,c] }

  Filters change the data-url of ul > li > a as follows:
    <a data-url="url?a="true"&b="true"&c="true" ... ></a>

  Any other tweaking can be done using the options hash
  'options' is of the form : 
    options = { 
      shared : < panel in toolbox >, (optional): if present, all tabs share the same panel
      klass : { => 'class' attributes to set on ... 
        root : ( .tabbable and .tabs-left are implicit )
        ul : ( root > ul: .nav & .nav-tabs are implicit )
        a : ( ul > a )
        content : ( .tab-content is implicit )
        div : ( content > div: .tab-pane is implicit )
      },
      id : {
        root : ... ,
        < others > ...
      } , 
      data : { => data-* attributes set on ul > li > a ( data-toggle="tab" is implicit )
        prev :
        url :
      } 

    }
###

emptyOptions = {
  klass : {
    root : "",
    ul : "",
    a : "",
    content : "",
    div : ""
  },
  id : {
    root : "",
    ul : "",
    a : "",
    content : "",
    div : null
  },
  data : {
    prev : ""
    url : ""
  }
}

window.leftTabs = {
  create : (root, json, optns = {}) ->
    root = if typeof root is 'string' then $(root) else root

    options = {}
    $.extend options, emptyOptions, optns # at the very least, ensure empty values 
    sharedPanel = options.shared

    html = $("<div id='#{options.id.root}' class='tabbable tabs-left #{options.klass.root}'></div>")

    # <ul> 
    html.appendTo root
    ul = $("<ul class='nav nav-tabs #{options.klass.ul}' id='#{options.id.ul}'></ul>")
    content = $("<div class='tab-content #{options.klass.content}' id='#{options.id.content}'></div>")
    ul.appendTo html

    content.appendTo html
    if sharedPanel?
      $("#toolbox").children("##{sharedPanel}").eq(0).clone().appendTo content

    # Collect the data-* attributes set on ul > li > a into one string. These are common to all <a>
    data = ""
    for j in ['prev', 'panel-url']
      data += " data-#{j}='#{options.data[j]}'" if options.data[j]?

    url = options.data.url
    if url?
      filters = json.filters
      if filters?
        url = if url.indexOf("?") > -1 then url else (url + "?")
        url += "&filter[#{f}]" for f in filters
      data += " data-url=#{url}" # -> final url - with filters

    data += " data-toggle='tab'"

    # Then, write the JSON
    for m,i in json.tabs
      # make the <li>

      liColour = m.colour
      disable = liColour is 'disabled' || liColour is 'nodata'

      li = "<li marker=#{m.id}"
      li += " colour=#{liColour}" unless disable
      if disable
        li += (if options.split then " class='split disabled'" else " class='disabled'")
      else
        li += (if options.split then " class='split'" else " class=''")

      li = $("#{li}" + "></li>")
      li.appendTo ul

      # 3. <a> 
      isTex = false
      if m.name.search(/\$.*\$/) isnt -1 # => TeX => wrap inside a <script>
        jaxified = karo.jaxify m.name
        script = "<script id='tex-tab-#{i}' type='math/tex'>#{jaxified}</script>"
        isTex = true
      else
        script = m.name

      if sharedPanel?
        aHtml = "<a href=##{sharedPanel} #{data} class='#{options.klass.a}'>"
        if options.split
          aHtml += "<div class='pull-left'>#{m.name}</div>"
          if options.writeBoth
            aHtml += "<div class='pull-right'>#{m.split}</div></a>"
          else
            aHtml += "<div class='pull-right'></div></a>"
          a = $(aHtml)
        else
          a = $("<a href=##{sharedPanel} #{data} data-toggle='tab' class='#{options.klass.a}'>#{script}</a>")
      else
        divId = if options.id.div? then options.id.div else "dyn-tab"
        a = $("<a href='##{divId}-#{m.id}' #{data} data-toggle='tab' class='#{options.klass.a}'>#{script}</a>")
        pane = $("<div class='tab-pane #{options.klass.div}' id='#{divId}-#{m.id}'></div>")
        pane.appendTo content

      a = a.appendTo li
      if isTex
        j = a.children('script')[0]
        MathJax.Hub.Queue ['Typeset', MathJax.Hub, j]

    # Once the left-tabs have been built, auto-click the first tab. There are 
    # almost no situations when this isn't required 
    firstTab = html.find('ul > li > a').eq(0)
    firstTab.click()
    return true

  add : (root, json, options = null) ->
    return false unless options? # this method only works w/ shared hrefs
    return false unless options.shared?
    return false unless options.data.url?

    root = if typeof root is 'string' then $(root) else root
    ul = root.children('ul.nav-tabs').eq(0)

    url = options.data.url
    hasId = url.search(":id") isnt -1

    for m in json.tabs
      ajax = if hasId then url.replace(":id", m.id) else url
      html = "<li><a marker=#{m.id} href='##{options.shared}' data-toggle='tab' data-url='#{ajax}'>#{m.name}</a></li>"
      $(html).prependTo ul
    firstTab = ul.find('li > a').eq(0)
    firstTab.click()
    return true
}
