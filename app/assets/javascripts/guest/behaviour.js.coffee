######################################################################
##
######################################################################

jQuery ->
  map = {}

  $('#register_student #nobtn').on 'click', ->
    $('#register_student').modal('hide')   

  $('#register_student #dismissbtn').on 'click', ->
    $('#register_student').modal('hide')   

  $('#register_teacher #nobtn').on 'click', ->
    $('#register_teacher').modal('hide')   

  $('#register_teacher #dismissbtn').on 'click', ->
    $('#register_teacher').modal('hide')   

  $('#contactus').on 'hidden', ->
    $('#theform')[0].reset()
    $('#formblurb').show()
    $('#ackblurb').hide()

  $('#register_student').on 'hidden', ->
    $('#studentform')[0].reset()
    $('#register_student #formblurb').show()
    $('#register_student #ackblurb').hide()
    $('#register_student #errblurb').hide()

  $('#register_teacher').on 'hidden', ->
    $('#teacherform')[0].reset()
    $('#register_teacher #formblurb').show()
    $('#register_teacher #ackblurb').hide()
    $('#register_teacher #errblurb').hide()

  $('#m-registrations').click ->
    $.get 'welcome/countries.json'
    return true

  $('#inputCountry').typeahead
    source: (query, process) ->
      countries = window.variables.countries
      names = []
      $.each(countries, (i, country) ->
        map[country.name] = country 
        names.push(country.name))
      process(names) 

    updater: (item) ->
      selectedCountry = map[item].alpha_2_code
      return item

