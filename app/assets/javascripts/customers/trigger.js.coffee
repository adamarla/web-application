jQuery ->

  $('#m-invoice').on 'shown', ->
    customer = $('#pane-cust .selected')
    customer_id = customer.attr "marker"
    customer_name = customer.children('.text')[0].innerHTML

    $('#m-invoice .title')[0].textContent = "Invoice for: " + customer_name
    $('#m-invoice #customer_id')[0].value = customer_id

  $('#payment_credits').change ->
    recalc_payment_amount()

  $('#payment_currency').change ->
    recalc_payment_amount()

  $('#btn-reset').click (event) ->
    event.preventDefault() 
    $('#fm-buy-credits')[0].reset()
    recalc_payment_amount()
    $('#m-buy-credits #message').addClass 'hide'

  $('#m-buy-credits').on 'shown', ->
    recalc_payment_amount()
    
  recalc_payment_amount = ->
    currency = $('#payment_currency').find('option:selected').val()
    quantity = $('#payment_credits').find('option:selected').val()
    rate = $('#payment_currency').find('option:selected').text().substring(3)
    if currency == "USD"
      amount = quantity * rate
      display = "$#{amount}"
    else
      amount = quantity * rate
      display = "₹#{amount}"
    $('#total-amt').val(display)

  recalc_refund_amount = ->
    currency = $('#payment_currency').find('option:selected').val()
    quantity = $('#payment_credits').find('option:selected').val()
    if currency == "USD"
      amount = quantity * 2
      display = "$#{amount}"
    else
      amount = quantity * 50
      display = "₹#{amount}"
    $('#total-amt').val(display)

