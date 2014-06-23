
############################################################################
## Bootstrap 
############################################################################

jQuery ->

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
  
  $('#m-enrollment-confirm').on 'click', '.line', (event) ->
    event.stopImmediatePropagation() 
    form = $(this).closest 'form'
    submitBtn = form.find("button[id='btn-enroll-me']")
    submitBtn.prop 'disabled', false
    return true

  $('#m-enrollment-confirm').on 'click', "button:not([type='submit'])", (event) ->
    event.stopImmediatePropagation() 
    mdl = $(this).closest '.modal'
    mdl.modal 'hide'
    return true

# [Abhinav]: Code below is for allowing students to write TeX as part of their 
# re-grade request. Worked sort of fine - but not perfectly. Can consider 
# revisiting and bringing it back sometime later

#  $('#m-dispute-2 form').submit ->
#    textbox = $(this).find('textarea').eq(0)
#    reason = textbox.val() 
#    jaxified = karo.jaxify reason
#    textbox.val jaxified
#    return true
