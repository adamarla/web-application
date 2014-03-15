jQuery ->
  
  ## $('input, textarea').placeholder()

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

  $('#payment_credits').change ->
    recalc_amount()

  $('#payment_currency').change ->
    recalc_amount()

  $('#btn-reset').click (event) ->
    event.preventDefault() 
    $('#fm-buy-credits')[0].reset()
    recalc_amount()
    $('#m-buy-credits #message').addClass 'hide'

  $('#m-buy-credits').on 'shown', ->
    recalc_amount()
    
  recalc_amount = ->
    currency = $('#payment_currency').find('option:selected').val()
    quantity = $('#payment_credits').find('option:selected').val()
    if currency == "USD"
      amount = quantity * 2
      display = "$#{amount}"
    else
      amount = quantity * 50
      display = "₹#{amount}"
    $('#total-amt').val(display)

