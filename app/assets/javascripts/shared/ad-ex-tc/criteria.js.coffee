

# JSON = { name: text-description, id: id, n_stars: number, badge: true | false }
# n_stars -> how many of the five stars to enable => low n_stars => high penalty 
# badge : true => show, false => don't show 

window.criteria = { 
  render : (json) ->
    obj = $('#toolbox > .criterion').clone()
    obj.find('.text').text json.name 
    obj.attr 'marker', json.id 

    # whether or not to show rating stars 
    showStars = if (json.stars? and json.stars is false) then false else true
    stars = obj.find '.stars'
    unless showStars 
      stars.remove() 
    else if json.n_stars > 0
      b = stars.children('.star')
      b.eq(j).addClass('enabled') for j in [0...json.n_stars]
      
    # whether or not to show badge 
    showBadge = if (json.badge? and json.badge is true) then true else false 
    obj.find('.badge').eq(0).remove() unless showBadge

    # set name on the checkbox 
    cb = obj.find("input[type='checkbox']")
    cb.attr 'name', "criterion[#{json.id}]"
    return obj
}

jQuery ->

  $('#pane-rubric-details').on 'click', 'button', (event) ->
    event.stopImmediatePropagation()
    id = $(this).attr 'id'
    switch id 
      when 'btn-new-criterion'
        $('#m-new-criterion').modal 'show'
    return true
