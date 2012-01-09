
window.selection = {
  list : []

  initialize : () ->
    selection.list = []

  add : (id) ->
    selection.list.push id

  remove : (id) ->
    at = selection.list.indexOf(id)
    return if at is -1
    selection.list.splice(at, 1)
}
