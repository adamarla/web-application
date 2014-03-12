
############################################################################
## Bootstrap 
############################################################################

jQuery ->
  $('#lnk-regrade-request').click (event) ->
    event.stopImmediatePropagation() 
    $('#mdl-dispute').modal 'show'
    return true

  $('#lnk-cancel-dispute').click (event) ->
    event.stopImmediatePropagation() 
    $('#mdl-dispute').modal 'hide'
    return false
