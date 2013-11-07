jQuery ->

  $('input, textarea').placeholder()

  $('#sk-confirm-identity').click ->
    $('#btn-enroll-me').removeAttr "disabled"
    return true
