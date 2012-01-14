
window.selection = {
  list : []

  initialize : () ->
    selection.list = []

  add : (id) ->
    alert 'Inside selection.add'
    at = selection.list.indexOf(id)
    if at is -1 then selection.list.push id
    alert " Pushing #{id}"

  remove : (id) ->
    alert 'Inside selection.remove'
    at = selection.list.indexOf(id)
    return if at is -1
    selection.list.splice(at, 1)
    alert " Removing #{id}"
}
