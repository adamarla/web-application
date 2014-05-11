
window.exploded = { 
  root : null, 
  tabs : null,

  hide : () -> 
    return false unless exploded.tabs?
    $(exploded.tabs).parent().addClass 'hide' # effectively $('#wide-2')
    return true 

  show : () ->
    return false unless exploded.tabs?
    $(exploded.tabs).parent().removeClass 'hide'
    return true 

  reset : () ->
    return true 

  render : (json) ->
    unless exploded.root?
      exploded.root = $('#pane-course-outline > .exploded')[0] 
      exploded.tabs = $('#wide-2 > ul')[0]

    for k in ['name', 'author', 'description']
      nd = $(exploded.root).find(".#{k}")[0]
      continue unless nd?
      $(nd).text json[k]

    for k in ['quizzes', 'lessons']
      isVideo = k is 'lessons'
      nd = $(exploded.root).find(".#{k}")[0]
      continue unless nd? 

      for j in json[k]
        html = "<div marker=#{j.id}>#{j.name}</div>"
        $(html).appendTo $(nd)

    #karo.tab.enable $(exploded.tabs).children('li')[0]
    exploded.show()
    return true
}
