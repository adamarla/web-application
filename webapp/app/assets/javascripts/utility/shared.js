
/*
Copy element X to Y. This needs to be done when - for example - one 
needs to make a search box by picking elements from the toolbox
*/ 

function copyXtoY(X,Y) { // X,Y are CSS-selectors
  var source = $(X) ; 
  var target = $(Y) ;

  if (source.length == 0 || target.length == 0) return false ;
  source.clone().appendTo(target) ;
  return true ;
} 

