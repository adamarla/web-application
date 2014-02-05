
jQuery ->

  $('#left').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    target = null # where to write the returned JSON
    key = null
    menu = null # ID of contextual menu to attach w/ each .line
    pgnUrl = null # base-url to be set on the paginator
    pgn = $('#left-paginator')
    clickFirst = false # whether or not to auto-click the first .line
    buttons = null

    if url.match(/verticals\/list/)
      target = $('#pane-mng-topics-1')
      key = 'verticals'
    else if url.match(/vertical\/topics/)
      karo.tab.enable 'tab-mng-topics-2'
      target = $('#pane-mng-topics-2')
      key = 'topics'
    else if url.match(/byCountry/)
      target = $('#pane-teacher-accounts')
      key = 'accounts'
    else if url.match(/inCountry/)
      target = $('#accounts-in-country')
      key = 'accounts'
      karo.empty target
    else if url.match(/school\/create/)
      $('#m-cust-create-form').modal 'hide' 
    else if url.match(/schools\/list/)
      target = $('#pane-customers')
      key = 'schools'
      menu = "per-customer"
      karo.empty target 
    else if url.match(/school/)
      school = json.school
      $('#customer-overview #cust-name').text school.name
      $('#customer-overview #cust-detail').text "#{school.city} #{school.phone}"
    else
      matched = false

    ############################################################
    ## Common actions in response to JSON
    ############################################################

    # Render lines in the panel
    lines.render target, key, json, menu, buttons, clickFirst, pgn, pgnUrl

    e.stopPropagation() if matched is true
    return true
