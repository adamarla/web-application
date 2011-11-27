
function editFormAction(formId, url, method) {
  // JS has no native support for default arguments. So, this is what one does
  method = (typeof method == 'undefined') ? 'post' : method ;

  var form = $(formId).children('form.formtastic:first') ;

  if (form.length == 1) { 
    form.attr('action', url) ; 
    form.attr('method', method) ;
  }
} 

function alignVertical( radioButtons ) { 
  var bs = $(radioButtons).buttonset() ;

  $(bs).find('label:first').removeClass('ui-corner-left').addClass('ui-corner-top') ;
  $(bs).find('label:last').removeClass('ui-corner-right').addClass('ui-corner-bottom') ;

  var max_w = 0 ; 
  $('label', radioButtons).each( function() {
     var w = $(this).width() ; 
     max_w = (w > max_w) ? w : max_w ;
  }) ;

  $('label', radioButtons).each( function() {
     $(this).width(max_w) ;
  }) ;
} 

