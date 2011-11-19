
function applyCommonBindings() 
{ 
    // Close parent dialog of a pop-up form 
    /*
    $('.new-entity').closest('div.ui-dialog').ajaxSend( function() {
        $(this).close() ;
    }) ;
    */
    
    var lettingYouKnow = $('#ajax-response-box').dialog({
        autoOpen : false, 
        dialogClass : 'notify',
        position : "right top"
    }) ;

    // close all tabs of an accordion before updating
    $('.accordion-form').each( function() { 
        var me = $('#benchmark_edit_pane') ;
        $(this).ajaxSend( function() { 
            $(this).accordion('activate', false) ;
        }).ajaxSuccess( function() { 
            //$('#ajax-response-box > p').text("Updated") ;
            $(lettingYouKnow).dialog('open').fadeOut(4000) ;
            // $('#ajax-response-box').dialog('open').fadeOut(3000) ;
        }) ;
    }) ;

} 

$( function() { 
    // Generally speaking, contain all forms first inside a <div> and call 
    // .dialog() only on this <div>. And if you want the resulting dialog to 
    // close whenever the submit button is clicked ( if there is one and 
    // whatever it might be ), then assign class="close-on-submit" attribute to the <div>

    $('.close-on-submit').ajaxSend( function() { 
        $(this).dialog('close') ;
    }) ; 

    // Generate accordions 
    $('.accordion-form').accordion({ header : '.accordion-heading', collapsible : true, active : false }) ;
    $('.submit-buttons').buttonset() ;
}) ; 


