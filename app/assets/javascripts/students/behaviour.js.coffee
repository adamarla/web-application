
jQuery ->

  $('#worksheets-link').click ->
    id = $('#control-panel').attr 'marker'
    $.get "student/testpapers.json?id=#{id}"
    return true

  ###
    On load, auto-click the first main-link > a that has attribute default='true'
  ###
  $('#main-links a[default="true"]:first').click()
