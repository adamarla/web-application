
jQuery ->

  $('#side-panel').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    url = settings.url
    matched = true

    if url.match(/student\/exams/)
      here = $('#published-worksheets')
      coreUtil.interface.displayJson json.exams, here, 'exam', {radio:true, link:true, ticker:false}
      
      # Point the <a> to the answer-key
      for m in json.exams
        r = m.exam
        id = r.id
        target = here.children(".swiss-knife[marker=#{id}]").eq(0)
        continue if target.length is 0
        a = target.children('a').eq(0)
        a.text 'answer key'
        a.attr 'href', "#{gutenberg.server}/atm/#{r.atm}/answer-key/downloads/answer-key.pdf"
    else
      matched = false

    e.stopPropagation() if matched is true
    return true

