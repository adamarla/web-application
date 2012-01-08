
jQuery ->

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teacher\/coverage/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    # Remove any prior error messages - unconditionally. You know
    # by now that you're going to be updating this panel
    $(this).find('.inline-error').remove()
    switch matched.pop()
      when 'teacher/coverage'
        here = $('#quiz-builder-form').find '.search-results:first'
        here.empty()

        coreUtil.mnmlists.redistribute json.macros
        coreUtil.mnmlists.customize 'macro', {}
        coreUtil.mnmlists.customize 'micro', {checkbox:true}

        results = coreUtil.mnmlists.asAccordion 'selected'
        results.appendTo here
        results.accordion({ header : '.accordion-heading', collapsible:true, active:false })

  .ajaxError (e,xhr,settings) ->
    matched = settings.url.match(/teacher\/coverage/)
    return if matched is null

    # Remove any prior error messages and search-results - unconditionally. 
    # You know by now that there has been an error !
    $(this).find('.search-results').empty()
    $(this).find('.inline-error').remove()

    switch matched.pop()
      when 'teacher/coverage'
        here = $('#quiz-builder-form')
        coreUtil.messaging.inlineError here, 'we apologize ...', "the requisite course isn't currently present in our database"
