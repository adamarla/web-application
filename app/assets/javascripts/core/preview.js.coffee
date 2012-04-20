
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
      p.popeye({ navigation : 'permanent', caption : 'permanent', zindex:1000})

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
      
    ###
      Hops backwards or forward to the next <li> in image list 
      that has 'hop' attribute = 'true'
    ###
    hop: (fwd = true, display = '#document-preview') ->
      display = if typeof display is 'string' then $(display) else display
      images = display.find('.ppy-imglist').eq(0)
      li = images.children('li')
      currId = preview.currIndex display

      nImages = li.length
      rocks = images.children('li[hop="true"]')
      current = li.eq(currId)

      if fwd
        hopTo = current.siblings("li[hop='true']:gt(#{currId}").eq(0)
        if hopTo.length isnt 0
          alert " abhinav --> #{li.index(hopTo)} --> #{hopTo.index()} "
        hopTo = if hopTo.length is 0 then rocks.eq(0) else hopTo
        rockAt = li.index(hopTo)
        guess2 = hopTo.index()
        pressBtn = display.find '.ppy-next:first'
        nClicks = if (rockAt >= currId) then rockAt - currId else (nImages - currId + rockAt)
        alert "#{nImages} --> #{currId} --> #{rockAt} --> #{nClicks} --> #{guess2}"
      else
        hopTo = images.children("li[hop='true']:lt(#{currId})").eq(0)
        hopTo = if hopTo.length is 0 then rocks.eq(rocks.length - 1) else hopTo
        rockAt = hopTo.index() - 1
        pressBtn = display.find '.ppy-prev:first'
        nClicks = if (rockAt < currId) then currId - rockAt else (nImages - rockAt) # wrapping back from 0
        alert "#{nImages} --> #{currId} --> #{rockAt} --> #{nClicks}"
      
      # Now click whichever button needs to be clicked 'nClicks' times
      for m in [1 .. nClicks]
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
          preview.hop false, images
          verticalTabs.children('li').eq(prev).children('a:first').click() if prev?
          
          ###
          backBtn = images.find '.ppy-prev:first'
          unless backBtn.length is 0
            backBtn.click()
          ###
        when 78 # 78 = 'N' for going to next
          preview.hop true, images
          verticalTabs.children('li').eq(next).children('a:first').click() if next?
          
          ###
          fwdBtn = images.find '.ppy-next:first'
          unless fwdBtn.length is 0
            fwdBtn.click()
          ###
      return true

    scrollSidePnlList: (event) ->
      return if preview.blockKeyPress

      ques = $('#side-panel').find '#question-options:first'
      return if ques.length is 0 or ques.hasClass 'ui-tabs-hide' # ie. if not showing

      options = ques.find '.swiss-knife'
      nQues = options.length
      pOuter = $('#document-preview > .ppy-outer:first')
      pCurr = pOuter.find('.ppy-current:first') # would not be present if # pages = 1
      currPg = if pCurr.length isnt 0 then parseInt(pCurr.text())-1 else 0 # Note: 0-indexed

      key = event.keyCode
      switch key
        when 66 # 66 = 'B' for going back 
          next = if currPg > 0 then currPg - 1 else nQues - 1
        when 78 # 78 = 'N' for going to next
          next = (currPg + 1) % nQues

      c = options.eq(currPg)
      n = options.eq(next)

      ###
      c.children().attr 'disabled', true
      n.children().attr 'disabled', false
      ###
      c.removeClass 'selected'
      n.addClass 'selected'
      return true

  }
