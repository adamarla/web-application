
get_input_date= (offset) ->
  input_date = new Date()
  input_date.setDate(new Date().getDate() - offset)
  "#{input_date.getDate()}/#{input_date.getMonth()+1}/#{input_date.getFullYear()}"

jQuery ->
  
  $('#m-register').on 'show', (event) ->
    honeyPot = $(this).find("input[id='jaal']")[0]
    $(honeyPot).addClass('chuppa-hua') if honeyPot?
    return true

  $('#live-phone > .carousel').carousel { interval: 2200 }

  $('.bkt-btn').on 'click', (event) ->
    offset = $(this).attr('days')
    if (offset != '0')
      input_date=get_input_date(+offset)
    else
      input_date='31/08/2016'
    $.get "../usage/by_user?input_date=#{input_date}"
    return true

  $('#wtp').on 'click', (event) ->
    $.get '../wtp/by_user'
    return true

  $('#datepicker').datepicker(
    dateFormat: "dd/mm/yy"
  )

