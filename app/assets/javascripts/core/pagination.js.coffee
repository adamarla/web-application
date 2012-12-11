
window.pagination = {
  initialize : (links, nEnabled) ->
    # 'links' = <div class='pagination'>
    return false if nEnabled > 8
    
    ul = $(links).children().eq(0)
    $(m).addClass 'disabled' for m in ul.children('li')
    for m in [0...nEnabled]
      ul.children('li').eq(m).removeClass 'disabled'
    return true

  enable : (pgs, m) ->
    return false if not pgs.hasClass 'pagination'
    m = if typeof m is 'string' then parseInt(m) else m
    alert m
    ul = pgs.children('ul').eq(0)
    li = ul.children 'li'
    nli = li.length
    for j in [0..nli]
      k = li.eq(j)
      if (j < m) then k.removeClass 'disabled' else k.addClass 'disabled'
    return true

  
  url : {
    add : (parameter, links) ->
      # parameter example = "klass=11". Will add a new &klass=* - 
      # or replace an existing klass=* - with the passed one
      p = parameter.split("=")[0]
      pagination.url.subtract p, links

      ul = $(links).children().eq(0)
      for m in ul.children('li')
        a = $(m).children('a').eq(0)
        href = a.attr 'href'
        href = "#{href}&#{parameter}" # add at the end
        a.attr 'href', href
      return true

    subtract : (parameter, links) ->
      # parameter example = "klass". Will remove '&klass=*' anywhere that it appears
      # in a links > ul > li > a href 
      ul = $(links).children().eq(0)
      for m in ul.children('li')
        a = $(m).children('a').eq(0)
        href = a.attr 'href'
        href = href.replace "[&]?#{parameter}=[\d]+[&]?",""
        a.attr 'href', href
      return true
  }
}
