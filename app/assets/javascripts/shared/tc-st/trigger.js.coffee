
jQuery ->
  
  $('#btn-show-solution').click (event) ->
    already = $(this).hasClass 'active'
    #ws = $("##{this.dataset.ws}")
    ws = $("##{this.getAttribute('data-ws')}")
    wsId = ws.attr('marker') || ws.parent().attr('marker')

    if already
      # student = $("##{this.dataset.id}")
      student = $("##{this.getAttribute('data-id')}")
      id = student.attr('marker') || student.parent().attr('marker')
      $(this).text "See Solution"
      karo.empty $(this).parent().next()
      $.get "ws/layout.json?ws=#{wsId}&id=#{id}"
    else
      $(this).text "Back to Scans"
      $.get "ws/preview.json?id=#{wsId}"

    return true

  ###
    Uploading ... 
  ###
  $('#m-upload-scans, #m-upload-sg').on 'click', 'button', (event) ->
    form = $(this).closest 'form'
    file = form.find("[type='file']").eq(0)
    warning = form.find(".subtext").eq(0)

    if file.val().length > 0 # => sth. selected
      warning.addClass 'hide' # => next = plz. select file first msg 
    else
      warning.removeClass 'hide'
      event.stopImmediatePropagation()
      return false
    return true



