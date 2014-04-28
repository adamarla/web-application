
# The json passed to render() is assumed to have the following minimum structure 
#    json = [ { name: ..., id: ... }, { name: ..., id: .... } ..... ]
#  The 'id' is used to create name label for the checkboxes / radio-buttons in the 
#  grid. The names are necessarily of the form - grid[j][k]

window.inputGrid = {
  root : null,
  table : null,

  initialize : (form) ->
    f = if typeof form is 'string' then $(form) else form
    inputGrid.root = f.find('.input-grid')[0]
    return false unless inputGrid.root?

    karo.empty f
    $('<table></table>').appendTo $(inputGrid.root)
    inputGrid.table = $(inputGrid.root).children('table')[0]
    return true

  render : (xjson = null, yjson = null, type = 'radio', flip = false) ->
    return false unless inputGrid.root?
    return false unless (xjson? and yjson?)
    isRadio = (type is 'radio') 

    # Render y-labels on top 
    html = "<tr><td></td>"
    for a in yjson
      html += "<td class='y-label'>#{a.name}</td>"
    html += "</tr>"
    $(html).appendTo $(inputGrid.table)

    # Render xjson items - one per row 
    for x in xjson
      html = "<tr><td class='x-label'>#{x.name}</td>"

      for y in yjson
        name = if flip then "grid[#{y.id}][#{x.id}]" else "grid[#{x.id}][#{y.id}]"
        btn = "<td><input type=#{type} name=#{name}></input></td>"
        html += btn
      html += '</tr>'
      $(html).appendTo $(inputGrid.table)
    return true 

  reset : () ->
    return false unless inputGrid.root?
    $(m).prop('checked', false) for m in $(inputGrid.root).find('input[type]')
    return true
}
