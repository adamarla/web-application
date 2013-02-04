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
      if json.status is "registered"
        $('#register_student #formblurb').hide()
        $('#register_student #errblurb').hide()
        $('#register_student #ackblurb').show()
      else
        $('#register_student #errblurb').show()
    else if url.match(/welcome\/register_teacher/)
      if json.status is "registered"
        $('#register_teacher #formblurb').hide()
        $('#register_teacher #errblurb').hide()
        $('#register_teacher #ackblurb').show()
      else
        $('#register_teacher #errblurb').show()

