jQuery ->

  $('input, textarea').placeholder()

  #####################################################################
  ## Auto-click teacher's tab in registration drop down
  #####################################################################
  $('#btn-register').click (event) ->
    karo.tab.enable 'tab-register-1'
    $('#m-register').modal('show')
    return true
