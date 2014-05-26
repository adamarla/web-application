
# JSON is assumed to have the following form: 
#   json = { tiles : [ { record }, { record }, .... { record } ] }
# where each 'record' is of the form 
#    record = { name: <>, id: <>, author: <>, num_quizzes: <>, num_lessons: <>, rating: <> }

window.tiles = { 
  root : null, 

  clear : () ->
    return false unless tiles.root? 
    $(m).empty() for m in $(tiles.root).children('.column')
    return true 

  hide : () -> 
    return false unless tiles.root? 
    $(tiles.root).parent().addClass 'hide' # parent is always #wide-1
    return true 

  show : () -> 
    return false unless tiles.root? 
    $(tiles.root).parent().removeClass 'hide' # parent is always #wide-1
    return true 

  render : (json) ->
    tiles.root = $('#course-list')[0] unless tiles.root? 
    blueprint = $('#toolbox > .tile')
    columns = $(tiles.root).children('.column')

    tiles.clear() 
    
    for m, index in json
      rawTile = blueprint.clone() 
      rawTile.attr 'marker', m.id

      for j in ['name', 'author', 'num_quizzes', 'num_lessons']
        nd = rawTile.find(".#{j}")[0]
        continue unless nd? 
        $(nd).text m[j]

        clm = columns[index % 3]
        rawTile.appendTo ($(clm)) if clm?
    return true
    
}

jQuery ->
  $('#wide').on 'click', '.tile', (event) -> 
    event.stopImmediatePropagation() 
    id = $(this).attr 'marker'
    $.get "load/course?id=#{id}"
    tiles.hide()
    return true
