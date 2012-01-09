
window.selection = {
  list : []

  initialize : () ->
    selection.list = []

  add : (id) ->
    selection.list.push id

  remove : (id) ->
    at = list.indexOf(id)
    return if at is -1
    list.splice(at, 1)
}
