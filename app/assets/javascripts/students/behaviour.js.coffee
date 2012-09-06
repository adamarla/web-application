
jQuery ->

  $('#worksheets-link').click ->
    id = $('#control-panel').attr 'marker'
    $.get "student/testpapers.json?id=#{id}"
    return true

  ###
    On load, auto-click the first main-link > a that has attribute default='true'
  ###
  $('#main-links a[default="true"]:first').click()

  ###
    When a radio-button within a flipchart is clicked. Copied from teachers/behaviour
  ###
  $('.flipchart').on 'click', 'input[type="radio"]', ->
    chart = $(this).closest '.ui-tabs-panel'
    marker = $(this).attr 'marker'
    id = chart.attr 'id'

    switch id
      when 'published-worksheets'
        tab = flipchart.containingTab $(this)
        testpaper = tab.attr 'marker'
        marker = $('#control-panel').attr 'marker'
        $.get "student/responses.json?id=#{marker}&testpaper=#{testpaper}"

    return true

  # When a 'constest grade' button is pressed 
  $('#my-grades').on 'click', 'input[type="button"]', (event) ->
    event.stopPropagation()
    $(this).addClass 'clicked'
    $(this).val 'done'
    $.get "contest?id=#{$(this).parent().attr 'marker'}"
    return true
