

###
  For when .tabbable.tab-left need to be created on the fly based on returned JSON

  JSON below has the following * fixed * form 
    {tabs : [{name : xyz, id : 123}, {name : abc, id : 789} .... ]}
  Only this kind of JSON will result in tabs

  Optionally, there can also be a key called :filters
    { tabs: [{ ... }, { ... } ... ], filters : [a,b,c] }

  Filters change the data-url-self of ul > li > a as follows:
    <a data-url-self="url?a="true"&b="true"&c="true" ... ></a>

  Any other tweaking can be done using the options hash
  'options' is of the form : 
    options = { 
      shared : < panel in toolbox >, (optional): if present, all tabs share the same panel
      klass : { => 'class' attributes to set on ... 
        root : ( .tabbable and .tabs-left are implicit )
        ul : ( root > ul: .nav & .nav-tabs are implicit )
        content : ( .tab-content is implicit )
        div : ( content > div: .tab-pane is implicit )
      },
      id : {
        root : ... ,
        < others > ...
      } , 
      data : {
        prev : # set on ul > li > a
        url : # set on ul > li > a
        ping : # set on ul
      } 

    }
###

emptyOptions = {
  klass : {
    root : "",
    ul : "",
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
    prev : "",
    url : ""
  }
}

window.leftTabs = {

  create : (root, json, optns = {}) ->
    root = if typeof root is 'string' then $(root) else root
    root.empty()

    options = {}
    $.extend options, emptyOptions, optns # at the very least, ensure empty values 
    pnId = options.shared

    html = $("<div id='#{options.id.root}' class='tabbable tabs-left #{options.klass.root}'></div>")

    # <ul> and <div class='tab-content'> 
    html.appendTo root
    ping = if options.data.ping? then options.data.ping else false
    ul = $("<ul class='nav nav-tabs #{options.klass.ul}' id='#{options.id.ul}' data-ping=#{ping}></ul>")
    content = $("<div class='tab-content #{options.klass.content}' id='#{options.id.content}'></div>")

    ul.appendTo html
    content.appendTo html

    if pnId?
      pn = $("#toolbox").children("##{pnId}").eq(0).clone()
      pn.attr 'id', "#{pnId}-shared"
      pn.appendTo content
      ul[0].setAttribute 'data-onepane', true

    # Collect the data-* attributes set on ul > li > a into one string. These are common to all <a>
    data = ""
    for j in ['prev', 'url-panel']
      data += " data-#{j}='#{options.data[j]}'" if options.data[j]?

    url = options.data.url
    if url?
      filters = json.filters
      if filters?
        url = if url.indexOf("?") > -1 then url else (url + "?")
        url += "&filter[#{f}]" for f in filters
      data += " data-url-self=#{url}" # -> final url - with filters

    data += " data-toggle='tab'"
    data += " data-reload='true'" if options.shared? 

    # Then, write the JSON
    for m,i in json.tabs
      # make the <li>

      liColor = m.color
      disabled = liColor is 'disabled' || liColor is 'nodata'

      li = $("<li marker=#{m.id}></li>").appendTo ul
      li.addClass 'disabled' if disabled

      # 3. <a> 
      isTex = false
      if m.name.search(/\$.*\$/) isnt -1 # => TeX => wrap inside a <script>
        jaxified = karo.jaxify m.name
        script = "<script id='tex-tab-#{i}' type='math/tex'>#{jaxified}</script>"
        isTex = true
      else
        script = m.name

      if pnId?
        href = "#{pnId}-shared"
        a = $("<a href=##{href} #{data}>#{script}</a>")
      else
        divId = if options.id.div? then options.id.div else "dyn-tab"
        a = $("<a href='##{divId}-#{m.id}' #{data}>#{script}</a>")
        pane = $("<div class='tab-pane #{options.klass.div}' id='#{divId}-#{m.id}'></div>")
        pane.appendTo content

      a = a.appendTo li
      leftTabs.ping.set(a[0], m.split, true) if m.split?

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

    attributes = options.data
    url = attributes.url
    prev = if attributes.prev is "" then null else attributes.prev
    hasId = url.search(":id") isnt -1

    for m in json.tabs
      ajax = if hasId then url.replace(":id", m.id) else url
      if prev?
        html = "<li><a marker=#{m.id} href='##{options.shared}' data-toggle='tab' data-prev='#{prev}' data-url-self='#{ajax}'>#{m.name}</a></li>"
      else
        html = "<li><a marker=#{m.id} href='##{options.shared}' data-toggle='tab' data-url-self='#{ajax}'>#{m.name}</a></li>"

      $(html).prependTo ul
    firstTab = ul.find('li > a').eq(0)
    firstTab.click()
    return true

  ping : { 
    # tab = <a data-toggle='tab'></a>

    condition : (tab) ->
      ul = $(tab).closest('ul')[0]
      return 'never' unless ul? 
      ret = ul.getAttribute 'data-ping'
      return ( if ret? then ret else 'never' ) 

    set : (tab, n, large = false) ->
      return false unless n?
      klass = if large then 'ping right' else 'ping'
      leftTabs.ping.unset tab
      $("<span class='#{klass}'>#{n}</span>").appendTo $(tab)
      return true

    unset : (tab) ->
      $(m).remove() for m in $(tab).children('span')
      return true 

    get : (tab) ->
      span = $(tab).children('span')[0]
      ret = if span? then $(span).text() else null
      return null unless ret? 
      isNumber = /^\d+$/.test(ret)
      return ( if isNumber then parseInt(ret) else ret )

    count : (model) ->
      # finds and counts objects 
      #   1. similarly placed in the DOM hierarchy as model
      #   2. with the same class attributes as 'model'
      uncles = $(model).parent().siblings()
      klass = $(model).attr 'class'
      n = uncles.children().filter("[class='#{klass}']").length
      return n

    up : (tab, large = false) -> 
      val = leftTabs.ping.get tab
      if val? 
        return false if typeof(val) is 'string'
      else 
        val = 0
      leftTabs.ping.set(tab, val + 1, large)
      return true

    down : (tab, large = false) ->
      val = leftTabs.ping.get tab
      if val? 
        return false if typeof(val) is 'string'
      else 
        val = 0
      leftTabs.ping.set(tab, val - 1, large)
      return true
  } 

}
