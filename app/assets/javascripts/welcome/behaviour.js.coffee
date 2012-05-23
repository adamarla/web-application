jQuery ->
    
  ###
  download_args =
    url: "#{gutenberg.server}/scanLoader/scanLoader.jnlp"
    async: false
  $('#download-button').click ->    
    $.ajax download_args
    $.get "#{gutenberg.server}/scanLoader/scanLoader.jnlp"
    xmlhttp = new XMLHttpRequest()
    xmlhttp.open("GET", "#{gutenberg.server}/scanLoader/scanLoader.jnlp", false)
    xmlhttp.send()
  ###  
  $("[href='#']").attr("href", "#{gutenberg.server}/scanLoader/scanLoader.jnlp")	
  