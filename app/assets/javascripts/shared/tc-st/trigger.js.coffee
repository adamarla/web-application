
jQuery ->
  
  $('#btn-show-solution').click (event) ->
    already = $(this).hasClass 'active'
    ws = $("##{this.dataset.ws}")
    wsId = ws.attr('marker') || ws.parent().attr('marker')

    if already
      student = $("##{this.dataset.id}")
      id = student.attr('marker') || student.parent().attr('marker')
      $(this).text "See Solution"
      karo.empty $(this).parent().next()
      $.get "ws/layout.json?ws=#{wsId}&id=#{id}"
    else
      $(this).text "Back to Scans"
      $.get "ws/preview.json?id=#{wsId}"

    return true


