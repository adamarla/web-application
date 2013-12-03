
window.shadow = {
  root: null,
  template: null,
  commentBox: null,

  over: (obj) ->
    obj = if typeof obj is 'string' then $(obj) else obj 
    id = obj.attr('id')
    id = if id? then "shadow-#{id}" else "shadow-X"

    shadow.template = $('#toolbox').children('.shadow')[0] unless shadow.template?
    $(shadow.root).remove() if overlay.root? 

    shadow.root = $(shadow.template).clone().appendTo obj
    shadow.commentBox = $(shadow.root).find('input')[0]
    $(shadow.root).attr 'id', id
    shadow.fall()

    $(shadow.root).focusin (event) ->
      event.stopPropagation()
      rubric.keyboard = false
      return true

    $(shadow.root).focusout (event) ->
      event.stopPropagation()
      rubric.keyboard = true
      return true

    $(shadow.commentBox).typeahead {
      source: fdb.history
    }

    return true


  fall: (percent = 8) ->
    return false unless shadow.root?
    percent = if percent < 8 then 8 else percent
    $(shadow.root).css "height", "#{percent}%"
    return true
}

jQuery ->
  $('.shadow').on 'click', (event) ->
    event.stopImmediatePropagation()
    alert '1'
    return true
