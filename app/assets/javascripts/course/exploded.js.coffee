
window.exploded = { 
  root : null, 
  tabs : null,

  hide : () -> 
    return false unless exploded.root?
    $(exploded.root).parent().addClass 'hide' # effectively $('#wide-2')
    return true 

  reset : () ->
    return true 

  initialize : (json) ->
    unless exploded.root?
      exploded.root = $('#course-outline')[0] 
      exploded.tabs = $(exploded.root).find('ul')[0]

    $(exploded.root).attr 'marker', json.id
    firstTab = $(exploded.tabs).children('li').eq(0).children('a')[0]
    karo.tab.enable firstTab

    for k in ['name', 'author', 'description']
      nd = $(exploded.root).find(".#{k}")[0]
      continue unless nd?
      $(nd).text json[k]

    # unhide #wide-2
    $(exploded.root).parent().removeClass 'hide'
    return true
}
