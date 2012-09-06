
jQuery ->

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    if url.match(/student\/testpapers/)
      here = $('#published-worksheets')
      coreUtil.interface.displayJson json.testpapers, here, 'testpaper', {radio:true, link:true}
      
      # Point the <a> to the answer-key
      for m in json.testpapers
        r = m.testpaper
        id = r.id
        target = here.children(".swiss-knife[marker=#{id}]").eq(0)
        continue if target.length is 0
        a = target.children('a').eq(0)
        a.text 'answer key'
        a.attr 'href', "#{gutenberg.server}/atm/#{r.atm}/answer-key/downloads/answer-key.pdf"
    else if url.match(/student\/responses/)
      here = $('#my-grades')
      coreUtil.interface.displayJson json.preview.questions, here, 'question', {button:true}
      swissKnife.setButtonCaption here, 'contest'
      reportCard.overview json.preview.questions, here, 'question'
      preview.loadJson json, 'locker'
    else
      matched = false

    e.stopPropagation() if matched is true
    return true

