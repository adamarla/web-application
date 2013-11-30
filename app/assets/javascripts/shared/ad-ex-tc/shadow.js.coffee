
window.shadow = {
  root: null,

  over: (obj) ->
    obj = if typeof obj is 'string' then $(obj) else obj 
    id = obj.attr('id')
    id = if id? then "shadow-#{id}" else "shadow-X"

    $(shadow.root).remove() if overlay.root? 
    transparentObj = $("<div id=#{id} class='shadow'></div>").appendTo obj
    shadow.root = transparentObj
    shadow.fall()
    return true


  fall: (percent = 50) ->
    return false unless shadow.root?
    return false if percent < 8 || percent > 100
    $(shadow.root).css "height", "#{percent}%"
    return true
}

jQuery ->
  $('.shadow').on 'click', (event) ->
    event.stopImmediatePropagation()
    alert '1'
    return true
