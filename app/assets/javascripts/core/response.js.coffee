
jQuery ->

  $('#wide').ajaxComplete (e, xhr, settings) ->
    matched = true
    url = settings.url
    json = $.parseJSON xhr.responseText

    if url.match('quiz/preview') or url.match('ws/preview')
      preview.loadJson json, 'atm'
    else
      matched = false

    e.stopImmediatePropagation() if matched
    return true

