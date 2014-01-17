
jQuery ->

  $('#left').ajaxComplete (e,xhr, settings) ->
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

    if url.match(/untagged\/list/)
      target = $('#pane-tag-pending')
      key = 'pending'
    else if url.match(/vertical\/topics/)
      target = $('#pane-vertical-topics')
      key = 'topics'
    else if url.match(/typeset\/new/)
      target = $('#pane-typeset-new')
      key = 'typeset'
      clickFirst = true
      menu = 'blockdb-slots'
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
      target = $('#pane-audit-review')
      clickFirst = true
      key = 'audit'
      menu = 'm-audit'
      karo.empty target
    else if url.match(/audit\/todo/)
      target = $('#pane-audit-todo')
      clickFirst = true
      key = 'audit'
      karo.empty target
    else if url.match(/audit\/open/)
      target = $('#pane-audit-todo')
      form = $('#m-audit-form').find('form').eq(0)
      $(m).prop('checked', false) for m in form.find("input[type='checkbox']")
      form.find("textarea").eq(0).val null
      $('#m-audit-form').modal 'hide'
      rubric.keyboard = true # re-enable keyboard input - if auditing during grading
    else if url.match(/audit\/close/)
      target = $('#pane-audit-review')
    else if url.match(/questions\/without_video/)
      target = $('#pane-video-pending')
      key = 'unwatchable'
      clickFirst = true
      karo.empty target
      menu = 'download-pg-1'
    else if url.match(/question\/add_video/)
      $('#m-upload-video-solution').modal 'hide'
      target = $('#pane-video-pending')
    else if url.match(/question\/gettex/)
      $('#m-edit-form #edit_tex').val = json.tex
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

    if url.match(/suggestion\/preview/)
      preview.loadJson json # locker
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true
