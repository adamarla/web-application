

# JSON 
# { 
#   text: description, 
#   id: critertion_id, 
#   kb: keyboard shortcut key - if any, 
#   bars : [0..5] -> penalty (0 = max. penalty, 5 = no penalty)
#   color : [ red | orange | blank ] -> if a red/orange flag issue 
# }

# n_stars -> how many of the five stars to enable => low n_stars => high penalty 
# badge : true => show, false => don't show 

window.criteria = { 
  render : (json) ->
    obj = $('#toolbox > .criterion').clone()
    obj.find('.text').text json.text 
    obj.attr 'marker', json.id 

    c = obj.children() 
    
    if not json.kb? and not json.reward? 
      # remove the first-child = .span2
      c.eq(1).removeClass('span10').addClass('span12')
      c.eq(0).remove()
    else 
      # keyboard short-cut 
      first = c.eq(0)
      if json.kb?
        first.find('.kb').eq(0).text json.kb
        obj[0].setAttribute 'data-kb', json.kb
      else
        first.find('.kb').remove()

      if json.reward? 
        rwd = first.find('.reward').eq(0) 
        rwd.css "width", "#{json.reward}%"
        rwd.addClass(json.color) if json.color?
      else
        first.find('.reward').parent().remove()

    # set name on the checkbox 
    cb = obj.find("input[type='checkbox']")
    cb.attr 'name', "criterion[#{json.id}]"
    return obj

  select : (nd) ->
    return false unless nd?
    return false unless $(nd).hasClass 'criterion'

    already = $(nd).hasClass 'selected' 
    cbx = $(nd).find("input[type='checkbox']").eq(0)
    icon = $(nd).find('i')[0]
    if already
      $(nd).removeClass 'selected'
      cbx.prop 'checked', false
      $(icon).removeClass('icon-white') if icon?
    else 
      $(nd).addClass 'selected' 
      cbx.prop 'checked', true
      $(icon).addClass('icon-white') if icon?
    return true 
}

jQuery ->

  $('#pane-rubric-details').on 'click', 'button', (event) ->
    event.stopImmediatePropagation()
    id = $(this).attr 'id'
    switch id 
      when 'btn-new-criterion'
        $('#m-new-criterion').modal 'show'
      when 'btn-update-assets'
        rbId = this.getAttribute 'data-id' # rubric ID 
        nd = assetMgr.root['used']
        ret = { used: new Array(), id: rbId }
        if nd?
          ul = $(nd).children('ul').eq(0)
          for li in ul.children('li')
            x = li.getAttribute('data-id')
            ret.used.push x

        spinner.setText 'Updating ...'
        $.post 'rubric/update', ret

    return true
