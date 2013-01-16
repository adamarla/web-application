
jQuery ->
  
  window.preview = {
    blockKeyPress: false,

    initialize : () ->
      wideX = $('#wide > #wide-X').eq(0)

      $(m).addClass 'hide' for m in wideX.siblings()
      wideX.removeClass 'hide'

      wideX.empty() if wideX.length isnt 0
      obj = $('#toolbox > #wp-preview').clone()
      obj.attr 'id', 'wide-X-carousel' # Working copy should have a different ID

      for a in obj.children('a')
        $(a).attr 'href', '#wide-X-carousel'
      obj.appendTo wideX
      return true

    execute : () ->
      obj = $('#wide-X > #wide-X-carousel')
      inner = obj.find('.carousel-inner').eq(0)
      first = inner.children('.item').eq(0)
      first.addClass 'active'
      obj.carousel { interval:15000 }
      return true

    loadJson : (json, source, obviousAlt = false) ->
      ###
        This method will create the preview in all situations - 
        when viewing candidate question in the 'vault', existing 
        quizzes in the 'mint' or stored response scans in the 'locker/atm'

        Needless to say, to keep the code here simple, the form of the passed 
        json should be consistent across all situations. And so, this is
        what it would be : 
          json.preview = { :id => 45, :scans => < single file-name > } OR
          json.preview = { :id => [56,67], :scans => [ [<images for '56'>], [<images for '67'>] ..] }
        where 'id' is whatever the preview is for and 'scans' are the list 
        of object-identifiers that need to be picked up. All interpretation 
        is context specific
      ###
      server = gutenberg.server
      switch source
        when 'mint' then base = "#{server}/mint"
        when 'vault' then base = "#{server}/vault"
        when 'atm' then base = "#{server}/atm"
        when 'locker' then base = "#{server}/locker"
        else base = null

      return false if base is null

      preview.initialize()

      # target = $('#document-preview').find 'ul:first'
      target = $('#wide > #wide-X').find('.carousel-inner').eq(0)
      roots = json.preview.id

      return false if roots.length is 0

      ###
        When we didn't have multi-part support, we had questions that could 
        be laid out on one page. We could therefore get away with specifying 
        just the folder name (in vault) for the question when generating previews
        of candidate questions because we knew that there would be atmost 
        JPEG within that folder

        However, multipart questions can span multiple pages. And we 
        need to be able to pick up all pages for preview. Couple this with the
        need to show multiple questions and we have no choice but to prepare
        for a situation where both 'preview.json.id' and 'preview.json.scans'
        are arrays
      ###

      if roots instanceof Array
        nRoots = roots.length
        multiRoot = true
      else
        nRoots = 1
        multiRoot = false

      scans = json.preview.scans

      # Relevant only when rendering yardstick examples 
      isMcq = false
      counter = 1

      for i in [0 .. nRoots - 1]
        if multiRoot
          root = roots[i]
          pages = scans[i]
        else
          root = roots
          pages = scans

        for page,j in pages
          hop = if (not multiRoot || (multiRoot && j == 0)) then true else false
          switch source
            when 'atm'
              full = "#{base}/#{root}/answer-key/preview/page-#{page}.jpeg"
              alt = "##{page}"
            when 'vault'
              full = "#{base}/#{root}/page-#{page}.jpeg"
              alt = "#{root}"
            when 'locker'
              full = "#{base}/#{root}/#{page}"
              alt = "pg-#{j+1}"
            else break

          img = "<div class=item hop=#{hop} m=#{j}><img alt=#{alt} src=#{full}></div>"
          $(img).appendTo target

      # Now, call the preview
      preview.execute()
      return true

    # Returns the index of the currently displayed image, starting with 0
    currIndex : () ->
      p = $('#wide > #wide-X')
      return -1 if p.length is 0

      images = p.children('.carousel-inner').eq(0).children('.item')
      index = images.index '.active'
      return index
      
    # Given a question UID, returns its position in the image-list (0-indexed)
    # Returns -1 if not found 

    isAt : (uid) ->
      return -1 if not uid?
      p = $('#wide > #wide-X')

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


