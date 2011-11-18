
$( function() { 
    // Generate accordions 
    $('.accordion-form').accordion({ header : '.accordion-heading', collapsible : true, active : false }) ;
    
    $('.submit-buttons').buttonset() ;

    // Bindings
    $('#new-benchmark-button').click( createNewBenchmarkDialog );

}) ; 
