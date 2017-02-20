
fetch_report = (offset) ->
  reportDate = new Date()
  reportDate.setDate(new Date().getDate() - offset)
  $.get "../usage/by_user?input_date=#{reportDate.getDate()}/#{reportDate.getMonth()+1}/#{reportDate.getFullYear()}"
  return true 

jQuery ->
  
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
    $.get '../usage/by_user?input_date=31/08/2016'
    return true

  $('#datepicker').datepicker(
    dateFormat: "dd/mm/yy"
  )

