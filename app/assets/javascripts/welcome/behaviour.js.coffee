
get_input_date= (offset) ->
  input_date = new Date()
  input_date.setDate(new Date().getDate() - offset)
  "#{input_date.getDate()}/#{input_date.getMonth()+1}/#{input_date.getFullYear()}"

format_date = (rawDate) ->
  rawDate.toISOString().substring(0,10).split("-").join("")

jQuery ->
  
  $('#m-register').on 'show', (event) ->
    honeyPot = $(this).find("input[id='jaal']")[0]
    $(honeyPot).addClass('chuppa-hua') if honeyPot?
    return true

  $('#live-phone > .carousel').carousel { interval: 2200 }

  $('.bkt-btn').on 'click', (event) ->
    from_date = format_date($('#fromDate').datepicker("getDate"))
    to_date = format_date($('#toDate').datepicker("getDate"))
    $.get "../usage/by_user?from_date=#{from_date}&to_date=#{to_date}"
    return true

  $('#wtp').on 'click', (event) ->
    $.get '../wtp/by_user'
    return true

  $('#fromDate').datepicker(
    dateFormat: "dd/mm/yy",
  )
  $('#fromDate').datepicker("setDate", new Date(2016, 8, 1))

  $('#toDate').datepicker(
    dateFormat: "dd/mm/yy"
  )
  $('#toDate').datepicker("setDate", new Date(2017, 2, 15))

