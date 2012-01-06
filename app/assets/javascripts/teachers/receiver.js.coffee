
jQuery ->

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teacher\/applicable_macros/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    # Remove any prior error messages - unconditionally. You know
    # by now that you're going to be updating this panel
    $(this).find('.inline-error').remove()
    switch matched.pop()
      when 'teacher/applicable_macros'
        here = $('#macro-search-form')
        displayJson json.macros, here, 'macro', {radio:true}
  .ajaxError (e,xhr,settings) ->
    matched = settings.url.match(/teacher\/applicable_macros/)
    return if matched is null

    # Remove any prior error messages and search-results - unconditionally. 
    # You know by now that there has been an error !
    $(this).find('.search-results').empty()
    $(this).find('.inline-error').remove()

    switch matched.pop()
      when 'teacher/applicable_macros'
        here = $('#macro-search-form')
        displayInlineError here, 'we apologize ...', 'the requisite course is not yet in our database'
