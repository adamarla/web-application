
############################################################################
## Bootstrap 
############################################################################

jQuery ->
  $('#btn-regrade').click (event) ->
    event.stopImmediatePropagation() 
    $('#m-dispute-1').modal 'show'
    return true

  $('#btn-cancel-dispute').click (event) ->
    event.stopImmediatePropagation() 
    $('#m-dispute-1').modal 'hide'
    return false

  $('#btn-dispute-next').click (event) ->
    event.stopImmediatePropagation()
    $('#m-dispute-1').modal 'hide'
    $('#m-dispute-2').modal 'show'
    return false

  $('#btn-show-tiles').click (event) ->
    event.stopImmediatePropagation() 
    exploded.hide()
    tiles.show()
    return true

#  $('#m-dispute-2 form').submit ->
#    textbox = $(this).find('textarea').eq(0)
#    reason = textbox.val() 
#    jaxified = karo.jaxify reason
#    textbox.val jaxified
#    return true
