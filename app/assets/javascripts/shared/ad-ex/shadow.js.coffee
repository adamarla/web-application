
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
      rubric.typing = true
      $('body').off 'keyup', rubric.pressKey
      return true

    $(shadow.root).focusout (event) ->
      event.stopPropagation()
      rubric.typing = false
      $('body').on 'keyup', rubric.pressKey
      return true

    $(shadow.commentBox).typeahead {
      source: fdb.history
    }

    return true


  fall: (percent = 8) ->
    return false unless shadow.root?
    percent = parseInt percent
    percent = if percent <= 8 then 8 else percent
    $(shadow.root).css "height", "#{percent}%"
    return true

  hide: () ->
    return false unless shadow.root?
    $(shadow.root).addClass 'hide' 
    return true

  unhide: () ->
    return false unless shadow.root?
    $(shadow.root).removeClass 'hide' 
    return true

}

jQuery ->
  $('.shadow').on 'click', (event) ->
    event.stopImmediatePropagation()
    return true
