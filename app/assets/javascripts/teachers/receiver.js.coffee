
jQuery ->

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    matched = settings.url.match(/teacher\/applicable_macros/)
    return if matched is null

    json = $.parseJSON xhr.responseText
    switch matched.pop()
      when 'teacher/applicable_macros'
        here = $('#macro-search-form')
        displayJson json.macros, here, 'macro', {radio:true}

