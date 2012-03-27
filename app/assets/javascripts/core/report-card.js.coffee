
window.reportCard = {

  ###
    The following method - overview - only overlays some data - styling & 
    otherwise - on an existing list of swiss-knives

    It assumes the following: 
      1. there is a list of swiss-knives to customize 
      2. the swiss-knives have a numerical 'marker' attribute
      3. the passed json has an 'id' key somewhere within it
      4. the passed json has a either a 'graded' or 'marks' or both keys also
  ###
  overview: (json, here, key) ->
    here = if typeof here is 'string' then $(here) else here

    for d, index in json
      e = d[key]
      id = e.id
      graded = e.graded
      marks = if graded then e.marks else null

      # Find the swiss-knife whose marker is = id
      sk = here.children(".swiss-knife[marker=#{id}]").eq(0)
      continue if sk.length is 0

      ticker = sk.children('div.micro-ticker').eq(0)
      if graded is false
        ticker.text 'pending'
      else if marks?
        ticker.text "#{marks}%"
    return true
}
