
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
