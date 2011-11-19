
function applyCommonBindings() 
{ 
    // Close parent dialog of a pop-up form 
    /*
    $('.new-entity').closest('div.ui-dialog').ajaxSend( function() {
        $(this).close() ;
    }) ;
    */

    // close all tabs of an accordion before updating
    $('.accordion-form').each( function() { 
        $(this).ajaxSend( function() { 
            $(this).accordion('activate', false) ;
        }) ;
    }) ;

} 
