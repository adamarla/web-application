
window.paginator = {
  initialize : (obj, baseUrl, tab) ->
    # baseUrl = data-self-url of a horizontal tab with :id, :prev resolved
    return false unless obj.hasClass 'paginator'

    paginator.url.set(obj, baseUrl)
    nEnable = tab.getAttribute 'data-pg-last'
    paginator.enable obj, nEnable
    return true

  enable : (pgs, m) ->
    return false unless m?
    return false unless pgs.hasClass 'paginator'
    
    m = if typeof m is 'string' then parseInt(m) else m
    if m > 1 then pgs.removeClass('hide') else pgs.addClass('hide')

    ul = pgs.children('ul').eq(0)
    li = ul.children 'li'
    nli = li.length
    for j in [0..nli]
      k = li.eq(j)
      if (j < m) then k.removeClass 'disabled' else k.addClass 'disabled'
    return true

  disable : (pgs) ->
    return false unless pgs.hasClass 'paginator'
    pgs.addClass 'hide'
    return true
  
  url : {
    set : (obj, baseUrl) ->
      ul = $(obj).children().eq(0)
      hasParams = baseUrl.indexOf('?') isnt -1
      for m,j in ul.children('li')
        a = $(m).children('a').eq(0)
        url = if hasParams then "#{baseUrl}&page=#{j+1}" else "#{baseUrl}?page=#{j+1}"
        a.attr 'href', url
      return true

    add : (parameter, obj) ->
      # parameter example = "klass=11". Will add a new &klass=* - 
      # or replace an existing klass=* - with the passed one
      p = parameter.split("=")[0]
      paginator.url.subtract p, obj

      ul = $(obj).children().eq(0)
      for m in ul.children('li')
        a = $(m).children('a').eq(0)
        href = a.attr 'href'
        href = "#{href}&#{parameter}" # add at the end
        a.attr 'href', href
      return true

    subtract : (parameter, obj) ->
      # parameter example = "klass". Will remove '&klass=*' anywhere that it appears
      # in a obj > ul > li > a href 
      ul = $(obj).children().eq(0)
      for m in ul.children('li')
        a = $(m).children('a').eq(0)
        href = a.attr 'href'
        href = href.replace "[&]?#{parameter}=[\d]+[&]?",""
        a.attr 'href', href
      return true
  }
}
