jQuery ->

  $('input, textarea').placeholder()

  $('#sk-confirm-identity').click ->
    $('#btn-enroll-me').removeAttr "disabled"
    return true

  $('#m-register #btn-register-student').click ->
    $('#who-are-you').addClass "hide"
    $('#pane-register-2').removeClass "hide"
    $('#fm-register-student').enableClientSideValidations()

  $('#m-register #btn-register-teacher').click ->
    $('#who-are-you').addClass "hide"
    $('#pane-register-1').removeClass "hide"
    $('#fm-register-teacher').enableClientSideValidations()

  $('#m-register').on 'hide', ->
    $('[id^=pane-register]').addClass "hide"
    $('#who-are-you').removeClass "hide"

