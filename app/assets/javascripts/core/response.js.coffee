
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

    if url.match(/quiz\/preview/)
      overlay.detach()
      preview.loadJson json # mint
    else if url.match(/exam\/layout/) or url.match(/load\/samples/)
      # load student scans 
      preview.loadJson json # locker
      # prep the feedback panel
      ulKlass = "span4" 
      contentKlass = "span7"

      if json.sandbox?
        sandbox = json.sandbox
        apprentice = json.apprentice 
        karo.tab.enable 'tab-samples'
      else 
        sandbox = false 
        apprentice = null 

      if json.user is 'Student' # a student viewing his/her own results
        target = '#pane-st-rc-2'
        writeBoth = true
        if json.disputable
          notifier.show('n-regrade-deadline', json) if json.notify
        else
          notifier.show('n-regrade-disallowed') 
      else if json.user is 'Teacher' # a teacher viewing grading results 
        target = '#pane-tc-rc-3'
        writeBoth = true
      else # a mentor reviewing grading work done by a novice grader 
        target = '#pane-samples'
        writeBoth = false 

      # render the left-tabs - one tab per question 

      karo.empty $(target)
      leftTabs.create target, json, {
        shared : 'q-fdb',
        klass : {
          root : 'purge-destroy',
          ul : ulKlass,
          content : contentKlass
        },
        data : {
          url : "load/fdb?id=:id&sandbox=#{sandbox}&a=#{apprentice}"
        }
      } 
      rubric.initialize '#q-fdb-shared'

      # prep preview. Scans will be loaded on-demand in response to view/fdb 
      $('#overlay-preview-carousel').removeClass 'hide'
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

    if url.match(/^account/)
      $('#m-edit-account').modal 'hide'
    else if url.match(/ask\/question/)
      json = $.parseJSON xhr.responseText
      $('#m-ask-a-question').modal 'hide'
      notifier.show 'n-question-received', json
    else if url.match(/reset\/password/)
      $('#m-reset-passwd').modal 'hide'
      json = $.parseJSON(xhr.responseText) 
      notifier.show('n-reset-passwd', json) if json.notify?
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

