jQuery ->
  ###
    Show/hide the main tabs on the welcome screen (on click)
  ###
  
  hide_all = ->
    $("#sign-in-form").hide()
    $("#about-us").hide()
    $("#how-it-works").hide()
    $("#download").hide()    
    
  hide_all()    
  $("#sign-in-form").show()
    
  $('#main-link').click ->
    hide_all()
    $("#sign-in-form").show()

  $('#about_us-link').click ->
    hide_all()
    $("#about-us").show()

  $('#how_it_works-link').click ->
    hide_all()
    $("#how-it-works").show()

  $('#download-link').click ->
    hide_all()
    $("#download").show()
      