
jQuery ->

  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/verticals\/list/)
      target = $('#pane-mng-topics-1')
      key = 'verticals'
    else if url.match(/vertical\/topics/)
      target = $('#pane-mng-topics-2')
      key = 'topics'
    else if url.match(/byCountry/)
      target = $('#pane-teacher-accounts')
      key = 'accounts'
    else if url.match(/inCountry/)
      target = $('#accounts-in-country')
      key = 'accounts'
      karo.empty target
    else if url.match(/schools\/list/)
      target = $('#pane-schools')
      key = 'schools'
      menu = 'institutional'
      karo.empty target 
    else if url.match(/school/)
      if settings.type == "POST"
        $('#m-school-create-form').modal 'hide' 
      else
        school = json.school
        $('#school-overview #school-name').text school.name
        $('#school-overview #school-detail').text "#{school.city} #{school.phone}"
    else if url.match(/list\/rubrics/)
      target = $('#my-rubrics')
      key = 'rubrics'
      clickFirst = true 
      menu = 'per-rubric'
    else if url.match(/rubric\/load/)
      karo.tab.enable 'tab-rubric-details'
      return assetMgr.render(json)
    else if url.match(/rubric$/) # only if its a POST request to create a new rubric
      target = $('#my-rubrics')
      key = 'rubrics'
      menu = 'per-rubric'
    else if url.match(/criterion/)
      $('#m-new-criterion').modal 'hide'
      return assetMgr.render(json.criteria, true)
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst

    e.stopPropagation() if matched is true
    return true
