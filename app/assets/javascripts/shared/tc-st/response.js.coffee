
jQuery ->

  $('#left').ajaxSuccess (e,xhr, settings) ->
    url = settings.url
    matched = true
    json = $.parseJSON xhr.responseText

    target = null # where to write the returned JSON
    parentKey = null
    childKey = null
    menu = null # ID of contextual menu to attach w/ each .single-line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .single-line

    if url.match(/ws\/list/)
      target = if json.user is "Student" then $('#pane-st-rc-1') else $('#pane-tc-rc-1')
      parentKey = 'wks'
      childKey = 'wk'
    else if url.match(/ws\/layout/)
      # load student scans 
      preview.loadJson json, 'locker'
      # prep the feedback panel
      splitTab = true
      if json.user is 'Student'
        target = '#pane-st-rc-2'
        writeBoth = false
      else
        target = '#pane-tc-rc-3'
        writeBoth = true

      leftTabs.create target, json, {
        shared : 'fdb-panel',
        split : splitTab,
        writeBoth : writeBoth,
        klass : {
          root : "purge-destroy",
          ul : "span3 nopurge-ever",
          content : "span8"
        },
        data : {
          url : "view/fdb.json?id=:id"
        }
      }
      return true
    else if url.match(/view\/fdb/)
      target = $('#fdb-panel')
      $(m).addClass('hide') for m in target.find('.requirement')
      target.find(".requirement[marker=#{id}]").eq(0).removeClass('hide') for id in json.fdb

      if json.split?
        active = target.parent().prev().children('li.active').eq(0)
        active.children('a.split').eq(0).text json.split
      return true
    else
      matched = false
    ############################################################
    ## Common actions in response to JSON
    ############################################################

    if target? and target.length isnt 0
      karo.empty target
      line.write(target, m[childKey], menu) for m in json[parentKey]

      # Enable / disable paginator as needed 
      if json.last_pg?
        pagination.enable pgn, json.last_pg
        # pagination.url.set pgn, pgnUrl

      # Auto-click first line - if needed
      target.children('.single-line').eq(0).click() if clickFirst

    e.stopPropagation() if matched is true
    return true
