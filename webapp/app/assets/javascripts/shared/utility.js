
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

function loadFormWithJsonData( form, data ){ 
  /* 
     This function tries to fill any formtastic form with any JSON data by iterating 
     over the form, matching keys in the JSON with field markers in the form

     The only catch is that 'data' should be flat, that is, it should
     not have any nesting. So, 'data' like below is OK : 
       { x:y, a:b, m:n ..... } 
     But something like {x:y, a:{b:c, d:e}, m:n ... } is not
  */ 

  var inputs = form.find('fieldset.inputs ol li') ;

  $(inputs).each( function(){
    var input = null ;  

    if ($(this).hasClass('string')) {
      input = $(this).children('input:first') ; 
    } else if ($(this).hasClass('select')) { 
      input = $(this).children('select:first') ;
    } else if ($(this).hasClass('boolean')) { 
      input = $(this).find('input[type="checkbox"]') ;
    } 

    var marker = (input != null) ? input.attr('marker') : null ;
    if (marker != null) {
        // alert(marker + ', ' + input.attr('id') + ', ' + data[marker]) ;
        input.val(data[marker]) ;
    } else {
        alert (' input element not found for ' + $(this).attr('class')) ;
    } 
  }) ;
} // end  

