
###
  This next function can be applied to either of the following 2 structures - 
  a simple table or a 'mega-form'. The start-point, therefore, has to be either
  a <div> or a <form>

    #table-name         <form> 
      #dump               #dump 
      .column              .column
      .column              .column
      .                    .
      .                    .
      .column              .column 
  
  The assumption is that everthing is first dumped into, well, the #dump
  and that then the children of #dump need to spread equally amongst the .columns. 
  When this function finishes executing, #dump should be empty

  The forms/tables this function is called on are ones where the columns need to be 
  of equal width. If the widths are to be different, then perhaps the other 
  functions in this file are the ones to use
###

window.arrangeDumpIntoColumns = (id) ->
  startPoint = if typeof id is 'string' then $(id) else id
  nToArrange = startPoint.children('#dump:first').children().length

  return if nToArrange is 0 # empty dump => everything arranged in columns

  parentWidth = startPoint.parent().width()
  nColumns = startPoint.children('.column').length
  columnWidth = 0.9 * (parentWidth / nColumns)
  perColumn = nToArrange / nColumns

  for column, m in startPoint.children '.column'
    $(column).width columnWidth

    for vertical, n in startPoint.children('#dump:first').children('.vertical-topic')
      vertical = $(vertical).detach()
      vertical.appendTo $(column)
      break if n > (perColumn - 1)

