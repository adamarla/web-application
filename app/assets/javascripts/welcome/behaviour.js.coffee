
fetch_report = (offset) ->
  reportDate = new Date()
  reportDate.setDate(new Date().getDate() - offset)
  $.post '../attempt/by_user', { report_date: "#{reportDate.getDate()}/#{reportDate.getMonth()+1}/#{reportDate.getFullYear()}" }
  return true 

jQuery ->
  
  ## $('input, textarea').placeholder()

  $('#m-register').on 'show', (event) ->
    honeyPot = $(this).find("input[id='jaal']")[0]
    $(honeyPot).addClass('chuppa-hua') if honeyPot?
    return true

  $('#live-phone > .carousel').carousel { interval: 2200 }

  $('#lastWeek').on 'click', (event) ->
    fetch_report(7)
  $('#lastMonth').on 'click', (event) ->
    fetch_report(30)
  $('#last2Months').on 'click', (event) ->
    fetch_report(60)
  $('#allTime').on 'click', (event) ->
    today = new Date()
    epoch = new Date(2015, 10, 16)
    fetch_report(Math.floor((today - epoch)/(1000*3600*24)))

  $('#datepicker').datepicker(
    dateFormat: "dd/mm/yy"
  )

