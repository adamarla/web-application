
############################################################################
## Bootstrap 
############################################################################

jQuery ->

  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    clickFirst = false # whether or not to auto-click the first .line
    lesson = null
    buttons = null

    if url.match(/sektion\/students/)
      if json.context is 'deepdive'
        target = $('#pane-dive-3')
        target.empty()
        wsDeepdive.students json
      else if json.context is 'list'
        target = $('#enrolled-students')
        karo.empty target
        buttons = [ { cbx: 'checked' } ]
      else
        target = $('#exb-sektions')
        lesson = 'exb-milestone-3'
        buttons = [ { cbx: 'checked' } ]
      key = "students"

    else if url.match(/share\/quiz/)
      $('#m-share-quiz').modal 'hide'
      if json.status is 'missing'
        notifier.show 'n-share-missing-teacher'
      else if json.status is 'error'
        notifier.show 'n-share-error'
      else if json.status is 'donothing'
        notifier.show 'n-share-already'
      else 
        notifier.show 'n-share-success'

    else if url.match(/quiz\/exams/)
      target = $("#pane-exb-existing")
      key = "exams"
      menu = 'per-ws'
      clickFirst = true
      lesson = 'publish-milestone-2'

    else if url.match(/exam\/summary/)
      target = $("#pane-tc-rc-2")
      karo.empty target
      key = "root"
      wsSummary json
      $('#lnk-rc-download')[0].setAttribute 'href', "ws/report_card?id=#{json.a}&format=csv"

    else if url.match(/teacher\/sektions/)
      if json.context is 'list'
        target = $('#pane-mng-sektions-1')
        lesson = 'mng-sektions-milestone-2'
        menu = 'per-sektion'
        clickFirst = true
      else
        target = $('#pane-dive-1')
      key = 'sektions'

    else if url.match(/sektion\/proficiency/)
      wsDeepdive.students json
      wsDeepdive.loadProficiencyData json

    else if url.match(/overall\/proficiency/)
      wsDeepdive.byStudent json

    else if url.match(/add\/sektion/)
      lesson = 'mng-sektions-milestone-3'
      $('#m-new-sk-1').modal 'hide'
      $('#lnk-mng-sektions').trigger 'click'

      # [102]: Add the new sektion as a left-tab so that teachers can start making 
      # worksheets without having to reload the site
      leftTabs.add '#exb-2', json, {
        shared : 'exb-sektions',
        data : {
          url : 'sektion/students?id=:id&context=exb&quiz=:prev',
          prev : 'tab-exb-quizzes'
        }
      }

    else if url.match(/ping\/sektion/)
      tab = $('#mng-sektions').find("a[marker=#{json.sektion.id}]")[0]
      karo.tab.enable tab if tab?

    else if url.match(/quiz\/edit/)
      monitor.add json
      notifier.show 'n-edit-quiz', json

    else if url.match(/update\/sektion/)
      target = $('#enrolled-students')

    else if url.match(/enroll\/named/)
      $('#m-new-sk-2').modal 'hide'
      notifier.show 'n-enrolled', json

    else if url.match(/preview\/names/)
      target = $('#new-sk-students')
      buttons = [ { cbx: 'names' } ]
      lines.columnify target, json.names, null, buttons
      for m in target.find '.line'
        # $(m).addClass 'disabled'
        cbx = sngLine.hiddenCbx(m)
        if cbx? 
          $(cbx).prop('checked', true) 
          $(cbx).attr 'value', $(cbx).parent().siblings('.text').eq(0).text()
      return true

    else if url.match(/set\/deadlines/)
      m = $('#m-exb-deadlines')
      m.modal 'hide'
    else if url.match(/def\/dist\/scheme/) # STEP 1: define distribution scheme 
      if json.apprentices?
        n = $('#m-exb-dist-scheme')
        f = n.find('form')
        f.attr 'action', "set/dist/scheme?id=#{json.id}"
        inputGrid.initialize(f)
        inputGrid.render json.apprentices, json.layout, 'checkbox', true
        n.modal 'show'
      else
        notifier.show 'n-no-apprentice'
    else if url.match(/set\/dist\/scheme/) # STEP 2: close modal 
        m = $('#m-exb-dist-scheme')
        m.modal 'hide'
    else if url.match(/ping\/for\/phones/)
      mdl = $('#m-phones') 
      columns = mdl.find('.column')
      $(m).empty() for m in columns
      for j,n in json.phones
        clm = columns.eq( n % 2 )
        $("<input type='tel' name='phone[#{j.id}]' class='span12'></input><span class='small-text orange'>#{j.name}</span>").appendTo clm
      mdl.modal 'show'
      return true
    else if url.match(/update\/phones/)
      mdl = $('#m-phones') 
      mdl.modal 'hide'
    else
      matched = false

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst

    # If in tutorial mode, then start the next tutorial - if any
    tutorial.start lesson if lesson?

    e.stopPropagation() if matched is true
    return true
