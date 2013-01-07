
jQuery ->

  $('#left').ajaxComplete (e,xhr, settings) ->
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
      target = $('#pane-teacher-rc-1')
      parentKey = 'wks'
      childKey = 'wk'
    else if url.match(/ws\/layout/)
      target = if json.user is 'Student' then '#pane-student-rc-2' else '#pane-teacher-rc-3'
      leftTabs.create target, json, {
        shared : 'fdb-panel',
        klass : {
          ul : "span4 nopurge-on-show",
          content : "span7"
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
      score = target.find('.score').eq(0)
      if score?
        score.children().eq(0).text json.marks
        score.children().eq(1).text "/ #{json.max}"
      return true
    else
      matched = false
    ############################################################
    ## Common actions in response to JSON
    ############################################################

    if target? and target.length isnt 0
      purge = if target.hasClass('writeonce') then target.children().length is 0 else true
      if purge
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
