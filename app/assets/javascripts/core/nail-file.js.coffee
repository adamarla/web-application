
window.nailFile = {
  customize : (element, json, anchors = [], qualifier = null) ->
    return if anchors.length is 0

    element.removeClass 'blueprint'
    element.attr 'marker', "#{json.id}"
    server = preview.server.local

    for label, index in anchors
      anchor = element.children('a').eq(index)
      anchor.removeClass 'hidden'
      anchor.attr 'marker', "#{json.id}"
      switch label
        when 'quiz-download'
          anchor.text 'download'
          anchor.attr 'href', "#{server}/atm/#{json.id}/answer-key/downloads/answer-key.pdf"
          anchor.attr 'type', label
        when 'preview'
          anchor.text 'preview'
          anchor.attr 'href', "#"
          anchor.attr 'type', label
        when 'test-download'
          anchor.text "#{json.name}"
          anchor.attr 'href', "#{server}/atm/#{qualifier}/#{json.id}/downloads/assignment-#{qualifier}-#{json.id}.pdf"
          anchor.attr 'type', label
        else
          anchor.attr 'href', '#'

    return true
}
