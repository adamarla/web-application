
jQuery ->

  $('#left').ajaxSuccess (e,xhr, settings) ->
    url = settings.url
    matched = true
    json = $.parseJSON xhr.responseText

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/ws\/list/)
      target = if json.user is "Student" then $('#pane-st-rc-1') else $('#pane-tc-rc-1')
      karo.empty target
      key = 'wks'
    else if url.match(/ws\/layout/)
      # load student scans 
      preview.loadJson json # locker
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
      $('#overlay-preview-carousel').removeClass 'hide'
      return true
    else if url.match(/view\/fdb/)
      target = $('#fdb-panel')
      $(m).addClass('hide') for m in target.find('.requirement')

      if json.fdb?
        target.find(".requirement[marker=#{id}]").eq(0).removeClass('hide') for id in json.fdb

      if json.split?
        active = target.parent().prev().children('li.active').eq(0)
        active.children('a.split').eq(0).text json.split

      # Set data-* attributes on the 'Read' and 'See' solution buttons
      b = target.closest('.tab-pane').find('.navbar').eq(0).find('button')

      btnVideo = b.filter("[id='btn-video-solution']")[0]
      btnSee = b.filter("[id='btn-show-solution']")[0]
      btnSee.setAttribute("data-#{m}", json[m]) for m in ['id','ws']

      if json.video?
        $(btnVideo).removeClass 'disabled'
        btnVideo.setAttribute 'data-video', json.video
        video.unload btnVideo
      else
        $(btnVideo).addClass 'disabled'

      if json.preview? 
        preview.loadJson json
        if json.comments?
          overlay.over $(preview.root)
          overlay.loadJson json.comments
      return true
    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst, pgn, pgnUrl

    e.stopPropagation() if matched is true
    return true

  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide').ajaxComplete (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match(/question\/preview/)
      $('#overlay-preview-carousel').addClass 'hide'
      $('#wide-wait').addClass 'hide'
      $('#wide-X').removeClass 'hide'
      preview.loadJson json # vault
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true


