
jQuery ->

  $('#left').ajaxSuccess (e,xhr, settings) ->
    url = settings.url
    matched = true
    json = $.parseJSON xhr.responseText

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .single-line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .single-line
    buttons = null

    if url.match(/ws\/list/)
      target = if json.user is "Student" then $('#pane-st-rc-1') else $('#pane-tc-rc-1')
      key = 'wks'
    else if url.match(/ws\/layout/)
      # load student scans 
      preview.loadJson json, 'locker'
      # prep the feedback panel
      splitTab = true
      if json.user is 'Student'
        target = '#pane-st-rc-2'
        ulKlass = "span3 nopurge-ever"
        contentKlass = "span8"
        writeBoth = false
      else
        target = '#pane-tc-rc-3'
        writeBoth = true
        ulKlass = "span4 nopurge-ever"
        contentKlass = "span7"

      leftTabs.create target, json, {
        shared : 'fdb-panel',
        split : splitTab,
        writeBoth : writeBoth,
        klass : {
          root : "purge-destroy",
          ul : ulKlass,
          content : contentKlass
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
      writeData = if key? then true else false
      karo.empty target

      # Render the returned JSON - in columns if so desired
      lines.columnify target, json[key], menu, buttons if writeData

      # Enable / disable paginator as needed 
      if json.last_pg?
        pagination.enable pgn, json.last_pg
        # pagination.url.set pgn, pgnUrl

      # Auto-click first line - if needed
      target.children('.single-line').eq(0).click() if clickFirst

    e.stopPropagation() if matched is true
    return true
