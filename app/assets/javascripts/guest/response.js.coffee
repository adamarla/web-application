############################################################################
## Bootstrap 
############################################################################

jQuery ->

  window.variables = {
    countries : []
  }

  $('#m-registrations').ajaxSuccess (e,xhr,settings) ->
    countries = window.variables.countries
    if countries.length is 0
      json = $.parseJSON xhr.responseText
      for c in json
        countries.push(c.country)
    return countries

  $('#modals').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    if url.match(/welcome\/register_student/)
      $('#register_student #formblurb').hide()
      $('#register_student #ackblurb').show()
    else if url.match(/welcome\/register_teacher/)
      $('#register_teacher > .modal-body > #formblurb').hide()
      $('#register_teacher > .modal-body > #ackblurb').show()

