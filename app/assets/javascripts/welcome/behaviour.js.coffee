jQuery ->
  ###
    Show/hide the main tabs on the welcome screen (on click)
  ###
  $('#about_us-link').click ->
    $("#sign_in_form").hide()
    $("#about_us").show()

  $('#main-link').click ->
    $("#sign_in_form").show()
    $("#about_us").hide()
      