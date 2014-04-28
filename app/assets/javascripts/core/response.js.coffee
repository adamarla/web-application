
jQuery ->
  $('form').ajaxSuccess (e, xhr, settings) ->
    matched = true
    url = settings.url

    if url is $(this).attr('action')
      $(m).val(null) for m in $(this).find("input[type='text'],input[type='password'],input[type='email']")
    else
      matched = false
    return true

  $('#wide').ajaxComplete (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match('quiz/preview') 
      preview.loadJson json # mint
    else if url.match(/exam\/layout/) or url.match(/load\/samples/)
      # load student scans 
      preview.loadJson json # locker
      # prep the feedback panel
      splitTab = true
      ulKlass = "span4" 
      contentKlass = "span7"

      if json.sandbox?
        sandbox = json.sandbox
        apprentice = json.apprentice 
        karo.tab.enable 'tab-samples'
      else 
        sandbox = false 
        apprentice = null 

      if json.user is 'Student'
        target = '#pane-st-rc-2'
        writeBoth = true
        if json.disputable
          notifier.show('n-regrade-deadline', json) if json.notify
        else
          notifier.show('n-regrade-disallowed') 
      else if json.user is 'Teacher'
        target = '#pane-tc-rc-3'
        writeBoth = true
      else 
        target = '#pane-samples'
        writeBoth = false 

      karo.empty $(target)
      leftTabs.create target, json, {
        shared : 'fdb-panel',
        split : splitTab,
        writeBoth : writeBoth,
        klass : {
          root : 'purge-destroy',
          ul : ulKlass,
          content : contentKlass
        },
        data : {
          url : "view/fdb.json?id=:id&sandbox=#{sandbox}&a=#{apprentice}"
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

      if json.regrade? # => only returned for students
        # we need to the next line to correctly submit the dispute form
        $('#tab-st-rc-2').parent().attr 'marker', json.a # json.a = graded-response-id

        regradeBtn = $('#pane-st-rc-2').find('button').filter("[id='btn-regrade']")[0]
        if regradeBtn
          if json.regrade.disable 
            $(regradeBtn).text json.regrade.name
            $(regradeBtn).prop 'disabled', true
          else 
            $(regradeBtn).text("Regrade #{json.regrade.name}") 
            $(regradeBtn).prop 'disabled', false

      # Set data-* attributes on the 'Read' and 'See' solution buttons
      b = target.closest('.tab-pane').find('.navbar').eq(0).find('button')

      btnVideo = b.filter("[id='btn-video-solution']")[0]
      btnSee = b.filter("[id='btn-show-solution']")[0]
      btnSee.setAttribute("data-#{m}", json[m]) for m in ['id','e']

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

    e.stopImmediatePropagation() if matched
    return true

  #####################################################################
  ## Close modal for changing account details on form submit 
  #####################################################################
  
  $('#control-panel').ajaxSuccess (e, xhr, settings) ->
    matched = true
    url = settings.url
    # json = if xhr? then $.parseJSON(xhr.responseText) else null

    if url.match('account')
      $('#m-edit-account').modal 'hide'
    else if url.match(/ask\/question/)
      json = $.parseJSON xhr.responseText
      $('#m-ask-a-question').modal 'hide'
      notifier.show 'n-question-received', json
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true

  $('#control-panel').ajaxError (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match('register')
      tabContent = $('#m-register').children('.tab-content').eq(0)
      active = tabContent.children('.active').eq(0)
      form = active.children('form').eq(0)
      errors = form.children('.error')

      for m in ['email', 'password', 'sektion']
        continue unless json.errors[m]?
        continue if json.errors[m].length is 0
        e = errors.filter(".#{m}").eq(0)
        e.removeClass 'hide'
        e.prev().find('p').eq(0).addClass 'hide'
    else
      matched = false

    # e.stopImmediatePropagation() if matched
    return true

