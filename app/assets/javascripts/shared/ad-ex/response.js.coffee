
jQuery ->

  $('#left').ajaxComplete (e,xhr, settings) ->
    url = settings.url
    matched = true
    json = $.parseJSON xhr.responseText

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/untagged\/list/)
      target = $('#pane-untagged-1')
      key = 'pending'
    else if url.match(/doubts\/pending/)
      target = $('#pane-doubts-1')
      key = 'doubts'
      menu = 'm-doubt'
      clickFirst = true
    else if url.match(/doubt\/preview/)
      preview.loadJson json
    else if url.match(/stab\/dates/)
      target = $('#pane-stabs-1')
      key = 'dates'
      stabs.initialize()
    else if url.match(/stabs\/dated/)
      stabs.pending.load json
    else if url.match(/grade\/stab/)
      if json.status is 'success'
        stabs.pending.next.stab()
    else if url.match(/vertical\/topics/)
      id = "##{json.context}-common-pane"
      target = $(id)
      key = 'topics'
    else if url.match(/typeset\/new/)
      target = $('#pane-typeset-new')
      key = 'typeset'
      clickFirst = true
      menu = 'blockdb-slots'
    else if url.match(/reupload/)
      mdl = $('#m-reupload')
      $(cbx).prop('checked', false) for cbx in mdl.find("input[type='checkbox']")
      mdl.modal 'hide'
      fdb.next.response()
    else if url.match(/typeset\/ongoing/)
      grp = $('#sg-ongoing').children().eq(0) # accordion-group
      grp.empty() # remove any previous data

      for m in json.ongoing
        hdr = $("<div class='accordion-heading' marker='#{m.id}'></div>")
        $("<a class='accordion-toggle' href='#sg-#{m.id}'>#{m.name}</a>").appendTo hdr
        a = hdr.children('a')[0]
        a.setAttribute 'data-parent', '#sg-ongoing'
        a.setAttribute 'data-toggle', 'collapse'
        bd = $("<div class='accordion-body collapse' id='sg-#{m.id}'></div>")

        inner = $("<div class='accordion-inner'></div>")
        inner.appendTo bd

        hdr.appendTo grp
        bd.appendTo grp
    else if url.match(/pages\/unresolved/)
      target = $('#unresolved-scans')
      buttons = [ { cbx: 'checked' } ]
      key = 'unresolved'
      clickFirst = true
    else if url.match(/unresolved\/preview/)
      preview.loadJson json  # scantray
    else if url.match(/resolve/)
      form = $('#form-resolve-scans')
      $(m).val(null) for m in form.find("input[type='text']")
      entries = form.find('.line')
      last = entries.filter("[class~='selected']")[0]
      $(last).remove() if last?
      entries.eq(0).click()
      return true
    else if url.match(/audit\/review/)
      target = $('#pane-audit-2')
      clickFirst = true
      key = 'audit'
      menu = 'm-audit'
      karo.empty target
    else if url.match(/audit\/todo/)
      target = $('#pane-audit-1')
      clickFirst = true
      key = 'audit'
      karo.empty target
    else if url.match(/audit\/open/)
      target = $('#pane-audit-1')
      form = $('#m-audit-form').find('form').eq(0)
      $(m).prop('checked', false) for m in form.find("input[type='checkbox']")
      form.find("textarea").eq(0).val null
      $('#m-audit-form').modal 'hide'
      rubric.typing = false
    else if url.match(/audit\/close/)
      target = $('#pane-audit-2')
    else if url.match(/questions\/without_video/)
      target = $('#pane-video-pending')
      key = 'unwatchable'
      clickFirst = true
      karo.empty target
      menu = 'download-pg-1'
    else if url.match(/question\/add_video/)
      $('#m-upload-video-solution').modal 'hide'
      target = $('#pane-video-pending')
    else if url.match(/examiner\/apprentices/)
      target = $('#pane-apprentices')
      key = 'apprentices'
    else if url.match(/disputes/)
      key = 'disputes'
      clickFirst = true
      target = $('#pane-disputes')
      menu = 'm-dispute'
    else if url.match(/dispute\/(accept|reject)/)
      target = $('#pane-disputes')
      $('#m-reject-dispute').modal 'hide'
    else if url.match(/question\/layout/)
      hint.initialize(json) if json.context is 'addhints'
    else
      matched = false


    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst

    e.stopPropagation() if matched is true
    return true

  ########################################################
  #  WIDE PANEL
  ########################################################

  $('#wide').ajaxComplete (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match(/suggestion\/preview/)
      preview.loadJson json # locker
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true
