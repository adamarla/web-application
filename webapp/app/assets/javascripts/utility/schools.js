
function displaySchoolListInSidePanel( schools ) {

  $.each( schools, function(index, data) {
    var school = data.school ; 
    var clone = $('#toolbox .radio-column:first').clone() ;
    var radio = clone.children('.radio:first') ;
    var label = clone.children('.content:first') ;

    /*
      Refer toolbox/radio_one_column.haml

      We need to set the following on the newly cloned element : 
        1. 'url' attribute on the radio-button 
        2. Text for the sibling <div> 
        3. 'colored' attribute on every alternate row 
        4. Uncheck the radio button
        5. Set 'marker' attribute on the radio button
    */ 

    radio.attr('url', 'school.json?id=' + school.id) ; // url = school.json?id=4
    radio.attr('marker', school.id) ;
    radio.prop('checked', false) ;
    label.text( school.name ) ;

    if (index % 2 == 1) clone.addClass('colored') ;
    clone.appendTo('#schools-summary > .data:first').hide().fadeIn('slow') ;
  }) ;
  
} 

