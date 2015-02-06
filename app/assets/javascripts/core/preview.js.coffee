
jQuery ->
  
  window.preview = {
    root: null,
    template: null,
    fallback: null,

    attach : (here = null) ->
      unless preview.fallback? 
        preview.fallback = $('#wide-X')[0]
      unless preview.template? 
        preview.template = $('#toolbox > #preview-carousel')[0] 
      
      if here?
        here = if typeof here is 'string' then $(here) else here
      else
        here = $(preview.fallback)

      # $(here) is going to be within #wide. Hide all siblings of 'here' 
      # and un-hide it only.
      $(sb).addClass('hide') for sb in here.siblings() 
      here.removeClass('hide')

      if preview.root? 
        p = $(preview.root).parent()
        if p.attr('id') is here.attr('id')
          preview.clear()
          return true
        else
          $(preview.root).remove()
          preview.root = null

      p = $(preview.template).clone().appendTo(here)[0]
      id = here.attr 'id'
      id = if id? then "preview-#{id}" else "preview-X"
      $(p).attr 'id', id
      preview.root = p

      # Bind the forward and back buttons to the new carousel
      # and ensure that their z-index is high enough so that they are always clickable
      for a in $(preview.root).children('a')
        $(a).attr('href',"##{id}") 
        $(a).css 'z-index', '10'

      $(preview.root).removeClass 'hide'
      return true
    
    detach : () -> 
      return false unless preview.root? 
      # $(preview.root).carousel 'destroy'
      $(preview.root).remove() 
      preview.root = null
      return true
      
    execute : () ->
      inner = $(preview.root).children('.carousel-inner').eq(0)
      first = inner.children('.item').eq(0)
      first.addClass 'active'

      # Hide controls if only image to be shown
      controls = inner.find('.item').length > 1
      for m in $(preview.root).children('a')
        if controls then $(m).removeClass('hide') else $(m).addClass('hide')

      $(preview.root).carousel { interval: false }
      return true

    clear : () ->
      return false unless preview.root?
      $(preview.root).children('.carousel-inner').empty()
      return true

    load : (img, source, here = null) ->
      return false unless source?
      img = if typeof img is 'string' then img else img.attr('name')
      return false unless img?

      preview.attach(here)
      target = $(preview.root).children('.carousel-inner').eq(0)
      server = gutenberg.server 

      item = $("<div class=item></div>").appendTo target
      $("<img alt='' src=#{server}/#{source}/#{img}>").appendTo $(item)
      preview.execute()
      return true

    loadJson : (json, here = null) ->
      ###
        json.preview = {
          source : [ vault | mint | minthril | scantray | scan-ashtray ],
          images : [ .... ], #  an N-element array of relative paths OR hashes = { path: xyz, id: <marker> } 
          captions : [ ..... ] # (optional) one caption per image 
        }

        This method will create, then append all the required <img> tags based 
        on what the passed JSON and the current gutenberg.server are
      ###
      return false unless json.preview?

      preview.attach(here)

      target = $(preview.root).children('.carousel-inner').eq(0)
      server = gutenberg.server 

      for img,i in json.preview.images
        item = $("<div class=item></div>").appendTo target
        
        isHash = typeof(img) isnt 'string' 
        pth = if isHash then img.path else img
        imgTag = $("<img alt='' src=#{server}/#{json.preview.source}/#{pth}>").appendTo $(item)

        if isHash 
          for k in Object.keys(img) 
            continue if k is 'path'
            imgTag[0].setAttribute(k, img[k])

        caption = if json.captions? then json.captions[i] else null
        $("<div class='carousel-caption top'><div>#{caption}</div></div>").appendTo($(item)) if caption?

      preview.execute()
      return true

    # Returns the index of the currently displayed image, starting with 0
    currIndex : () ->
      images = $(preview.root).children('.carousel-inner').eq(0).children('.item')
      index = images.index '.active'
      return index
      
    # Given a question UID, returns its position in the image-list (0-indexed)
    # Returns -1 if not found 

    isAt : (uid) ->
      return -1 if not uid?
      p = $(preview.root)

      images = p.find '.carousel-inner > .item'
      posn = -1

      for m,j in images
        img = $(m).children('img').eq(0)
        if img.attr('alt') is uid
          posn = j
          break
      return posn

    jump : (from, to) ->
      return if not to?
      p = $('#wide > #wide-X')

      p.carousel to
      return true

    ###
      Hop backwards/forwards one image. And when displaying the list of questions 
      to pick from for a quiz, update the side panel bearing in mind that some 
      questions can span multiple pages/images
    ###

    hop: (fwd = true) ->
      p = $('#wide > #wide-X')
      active = p.find('.carousel-inner > .item.active').eq(0)
      next = if fwd then active.next(".item[hop='true']") else active.prevAll(".item[hop='true']")
      active.removeClass 'active'
      next.addClass 'active'
      return true

  }


