
window.exploded = { 
  root : null, 
  tabs : null,
  visible : false, 

  hide : () -> 
    exploded.visible = false
    return false unless exploded.root?
    $(exploded.root).parent().addClass 'hide' # effectively $('#wide-2')
    return true 

  reset : () ->
    return true 

  initialize : (json) ->
    unless exploded.root?
      exploded.root = $('#course-expld-view')[0] 
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
    exploded.visible = true
    return true

  update : (json) ->
    # Updates the exploded view with data returned by ping/queue
    return false unless exploded.visible 
    return false unless json.worksheets?
    list = $('#pane-expld-quizzes').find('.line')
    for w in json.worksheets 
      ln = list.filter("[marker=#{w.q}]")[0]
      if ln?
        $(ln).children('.subtext').eq(0).remove()
        $("<a href=#{w.path} target=_blank>PDF</a>").appendTo($(ln)) 
        $(ln).removeClass 'disabled'
    return true
    
}
