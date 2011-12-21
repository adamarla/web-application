
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
  maxWidth = parentWidth/nColumns
  columnWidth = 0.9*maxWidth
  perColumn = nToArrange / nColumns

  for column, m in startPoint.children '.column'
    $(column).width maxWidth
    $(column).css 'margin-left', m * maxWidth

    for broadTopic, n in startPoint.children('#dump:first').children('.broad-topic')
      broadTopic = $(broadTopic).detach()
      broadTopic.appendTo $(column)
      break if n >= perColumn


###

function arrangeDumpIntoColumns(id) { 
  var startPoint = $(id) ; 
  var nToArrange = $(startPoint).children('#dump:first').children().length ; 

  if (nToArrange == 0) return ; // empty dump => everything arranged in columns

  var parentWidth = $(startPoint).parent().width() ; 
  var nColumns = $(startPoint).children('.column').length ;
  var maxWidth = (parentWidth / nColumns) ;
  var columnWidth = maxWidth * 0.90 ; // Just to be safe, use 90% of available width
  var perColumn = (nToArrange / nColumns) ; 
  var index = 0 ;

  // alert(nColumns + ', ' + perColumn) ;

  $(startPoint).children('.column').each( function() { 
    var currColumn = $(this) ; 
    var nArranged = 0 ;

    $(this).width(columnWidth) ;
    $(this).css('margin-left', index * maxWidth) ;

    $(startPoint).children('#dump:first').children().each( function() {
      if (nArranged >= perColumn) return false; 

      var me = $(this).detach() ; 
      me.appendTo(currColumn) ;
      nArranged += 1 ;
      // alert(' Ab dekho' ) ;
    }) ; 
    // alert(' Broken from loop with nArranged = ' + nArranged) ;
    $(this).fadeIn('slow') ;
  }) ; 
} 
###
