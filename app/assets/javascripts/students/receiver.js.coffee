
jQuery ->

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    if url.match(/student\/testpapers/)
      here = $('#published-worksheets')
      coreUtil.interface.displayJson json.testpapers, here, 'testpaper'
    else
      matched = false

    e.stopPropagation() if matched is true
    return true

