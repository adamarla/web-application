
function panelXHasY( X, Y ) { // X, Y = CSS selectors 
  var child = $(X).children().first() ; 
  var id = (child.length == 0) ? null : child.attr('id') ; 

  if (id != null && id == Y) return true ; 
  return false ;
} 

function clearPanel( id ){ 
  var moveMe = $(id).children().first() ; 
  if (moveMe.length == 0) return ;

  // If 'moveMe' has any data under a <div class="data empty-on-putback"> within its 
  // hierarchy, then empty that data first. Note, that it is assumed that 
  // the emptied out data can re-got from an AJAX query. In other words, 
  // if some data is too valuable to lose, then *do not* put it under .data.empty-on-putback

  var data = moveMe.find('.data.empty-on-putback') ;
  data.each( function() { $(this).empty() ; } ) ;

  moveMe = moveMe.detach() ; 
  moveMe.appendTo("#toolbox") ;
} 

/*
  For any link in the #control-panel - be it a #minor-link or a #major-link - 
  retain only the panels specified in its 'side', 'middle', 'right' and/or 'wide' 
  attributes - with one caveat : 
    #minor-links *cannot* remove the 'side' panel placed on the page by a #major-link
*/ 

function refreshView( linkId ) {
  var link = $('#' + linkId) ; 

  $.each(['side','middle','right','wide'], function(index, panelType) {
    var panelId = link.attr(panelType) ;
    var currPanelId = '#' + panelType + '-panel' ;

    if (panelId == null) { // no attribute => don't need this panelType
      if (link.hasClass('minor-link')) {
        if (panelType == 'side') return true ;
      } 
      clearPanel(currPanelId) ;
      $(currPanelId).addClass('hidden') ;
    } else {
      var currPanel = $(currPanelId).children().first() ; 

      if (currPanel == $(panelId)) return true ; // already loaded => do nothing
      clearPanel(currPanelId) ; 
      $(currPanelId).removeClass('hidden') ;
      $(panelId).appendTo(currPanelId).hide().fadeIn('slow') ;
    } 
  }) ;
} 


