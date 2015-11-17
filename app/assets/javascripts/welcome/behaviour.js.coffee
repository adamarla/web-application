jQuery ->
  
  ## $('input, textarea').placeholder()

  $('#m-register').on 'show', (event) ->
    honeyPot = $(this).find("input[id='jaal']")[0]
    $(honeyPot).addClass('chuppa-hua') if honeyPot?
    return true

  $('#live-phone > .carousel').carousel { interval: 2200 }
