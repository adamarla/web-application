
jQuery ->
  
  window.preview = {
    blockKeyPress: false,

    initialize : (here = '#wide-panel') ->
      here = if typeof here is 'string' then $(here) else here

      # First, remove any previous #document-preview
      previous = $('#document-preview')
      if previous.length isnt 0
        p = previous.parent()
        if p.hasClass 'ppy-placeholder'
          p.remove()
        else
          previous.remove()

      # Now, place a new element within which the image-list will be 
      # appended 
      clone = $('#blueprint-document-preview').clone()
      clone.attr 'id', 'document-preview'
      clone.appendTo here
      here.removeClass 'hidden'
      return true

    execute : () ->
      p = $('#document-preview')
      return if p.parent().hasClass '.ppy-placeholder'
      p.popeye({ navigation : 'hover', caption : 'permanent', zindex:1000, opacity:0.8})

    loadJson : (json, source) ->
      ###
        This method will create the preview in all situations - 
        when viewing candidate question in the 'vault', existing 
        quizzes in the 'mint' or stored response scans in the 'locker/atm'

        Needless to say, to keep the code here simple, the form of the passed 
        json should be consistent across all situations. And so, this is
        what it would be : 
           json = { :preview => { :id => 45, :indices => [ list of numbers ] } }
        where 'id' is whatever the preview is for and 'indices' are the list 
        of object-identifiers that need to be picked up. All interpretation 
        is context specific
      ###
      server = gutenberg.server
      switch source
        when 'mint' then base = "#{server}/mint"
        when 'vault' then base = "#{server}/vault"
        when 'atm' then base = "#{server}/atm"
        when 'frontdesk-yardsticks' then base = "#{server}/front-desk/previews/yardsticks"
        when 'locker' then base = "#{server}/locker"
        else base = null

      return false if base is null

      preview.initialize()

      target = $('#document-preview').find 'ul:first'
      roots = json.preview.id

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
              thumb = "#{base}/#{root}/answer-key/preview/page-#{page}.jpeg"
              alt = "##{page}"
            when 'vault'
              thumb = "#{base}/#{root}/page-#{page}.jpeg"
              full = "#{base}/#{root}/page-#{page}.jpeg"
              alt = "#{root}"
            when 'frontdesk-yardsticks'
              type = json.preview.mcq[j]
              if type isnt isMcq
                counter = 1
                isMcq = type

              thumb = "#{base}/#{page}/thumbnail.jpeg"
              full = "#{base}/#{page}/preview.jpeg"
              alt = if isMcq then "M#{counter++}" else "G#{counter++}"
            when 'locker'
              thumb = "#{base}/#{page}"
              full = "#{base}/#{page}"
              alt = "pg-#{j+1}"
            else break

          img = $("<li hop=#{hop}><a href=#{full}><img src=#{thumb} alt=#{alt}></a></li>")
          img.appendTo target

      # Now, call the preview
      preview.execute()
      return true

    # Returns the index of the currently displayed image, starting with 0
    currIndex : (display = '#document-preview') ->
      display = if typeof display is 'string' then $(display) else display
      return null if display.hasClass 'hidden'
      counter = display.find '.ppy-counter:first'
      counter = if counter.length isnt 0 then parseInt(counter.text()) - 1 else 0
      return counter

    # Given a question UID, returns its position in the image-list (0-indexed)
    # Returns -1 if not found 

    isAt : (uid, display = '#document-preview') ->
      return -1 if not uid?
      display = if typeof display is 'string' then $(display) else display
      return -1 if display.hasClass 'hidden'

      images = display.children('.ppy-imglist').eq(0).children('li[hop="true"]')
      at = -1

      for image, j in images
        title = $(image).find('img:first').attr('alt')
        if title is uid
          at = images.index image
          break
      return at

    jump : (from, to, display = '#document-preview') ->
      return if not from? or not to?
      return if to is -1

      display = if typeof display is 'string' then $(display) else display
      return if display.hasClass 'hidden'

      images = display.children('.ppy-imglist').eq(0).children('li')
      last = images.length - 1

      if to > false
        fwd = true
        steps = to - from
      else
        fwd = false
        steps = from - to

      if steps > (last / 2)
        fwd = not fwd
        steps = if fwd then (last - to + from) else (last - from + to)

      alert "#{fwd} ---> #{steps}"

      btn = if fwd then display.find('.ppy-next:first') else display.find('.ppy-prev:first')
      for j in [1..steps]
        btn.click()
      return true

    ###
      Hop backwards/forwards one image. And when displaying the list of questions 
      to pick from for a quiz, update the side panel bearing in mind that some 
      questions can span multiple pages/images
    ###

    hop: (fwd = true, display = '#document-preview') ->
      display = if typeof display is 'string' then $(display) else display
      images = display.find('.ppy-imglist').eq(0)
      li = images.children('li')
      nImages = li.length
      current = preview.currIndex display # 0-indexed
      hcurr = li.eq(current).attr 'hop'

      if fwd
        next = if (current + 1) < nImages then (current + 1) else 0
        pressBtn = display.find '.ppy-next:first'
      else
        next = if current is 0 then nImages - 1 else current - 1
        pressBtn = display.find '.ppy-prev:first'

      hnext = li.eq(next).attr 'hop'
      if fwd
        # update side-panel if (hcurrent -> hnext) = (false -> true) OR (true -> true)
        preview.sideScrollFwd(true) if hnext is "true"
      else
        # update side-panel if (hcurrent -> hnext) = (true -> false) OR (true -> true)
        preview.sideScrollFwd(false) if hcurr is "true"
      pressBtn.click()
      return true


    hardSetImgCaption : (imgId, newCaption, previewId = 0) ->
      return if (not imgId? or not newCaption?)
      ###
      'oliveOil' is defined in Popeye's code (vendor/assets/javascripts)
      It is of the form [0,[...],1,[...],2,[...] .... ]. Each number represents
      a preview (yes, there can be > 1) and the following array has the captions
      for that preview
      ###
      captions = oliveOil[2*previewId + 1]
      return if imgId >= captions.length

      captions[imgId] = newCaption
      return true

    softSetImgCaption : (newCaption, display = '#document-preview') ->
      display = if typeof display is 'string' then $(display) else display
      return null if display.hasClass 'hidden'
      caption = display.find '.ppy-text:first'
      return null if caption.length is 0
      caption.text newCaption
      return true

    scrollImg: (images, event) ->
      verticalTabs = $('#side-panel').find '.vertical-tabs:first > ul' # if present, we need the ui-tabs-nav
      unless verticalTabs.length is 0 # => previewing yardsticks
        numTabs = verticalTabs.find('li').length
        index = verticalTabs.find('li.ui-tabs-selected').index()
        next = (index + 1) % numTabs
        prev = if index > 0 then index - 1 else numTabs - 1

      key = event.keyCode
      switch key
        when 66 # 66 = 'B' for going back 
          n = preview.hop false, images
          verticalTabs.children('li').eq(prev).children('a:first').click() if prev?
        when 78 # 78 = 'N' for going to next
          n = preview.hop true, images
          verticalTabs.children('li').eq(next).children('a:first').click() if next?
      return true

    sideScrollFwd: (fwd) ->
      return if preview.blockKeyPress

      ques = $('#side-panel').find '#question-options:first'
      return if ques.length is 0 or ques.hasClass 'ui-tabs-hide' # ie. if not showing

      options = ques.find('.swiss-knife')
      nOptions = options.length
      selected = options.filter('.selected').first()
      current = if selected.length isnt 0 then selected.index() else 0

      if fwd
        next = (current + 1) % nOptions
      else
        next = if current > 0 then current - 1 else nOptions - 1

      for m,j in options
        if j == next then $(m).addClass('selected') else $(m).removeClass('selected')
      return true

  }


