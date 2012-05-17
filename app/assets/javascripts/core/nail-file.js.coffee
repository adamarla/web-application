
window.nailFile = {
  customize : (element, json, anchors = [], parentJson = null) ->
    return if anchors.length is 0

    element.removeClass 'blueprint'

    ###
      Generally speaking, give preference to a randomized_id - if available -
      over plain id
    ###
    id = if json.randomized_id? then json.randomized_id else json.id

    element.attr 'marker', id
    server = gutenberg.server

    for label, index in anchors
      anchor = element.children('a').eq(index)
      anchor.removeClass 'hidden'
      anchor.attr 'marker', id
      switch label
        when 'quiz-download'
          anchor.text 'download pdf'
          anchor.attr 'href', "#{server}/atm/#{id}/answer-key/downloads/answer-key.pdf"
          anchor.attr 'type', label
        when 'preview'
          anchor.text 'preview'
          anchor.attr 'href', "#"
          anchor.attr 'type', label
        when 'test-download'
          anchor.text "#{json.name}"
          anchor.attr 'href', "#{server}/atm/#{parentJson.randomized_id}/#{json.id}/downloads/assignment-#{parentJson.id}-#{json.id}.pdf"
          anchor.attr 'type', label
        else
          anchor.attr 'href', '#'

    return true
}
