
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
      root = json.preview.id
      scans = json.preview.indices

      # Relevant only when rendering yardstick examples 
      isMcq = false
      counter = 1

      for scan,j in scans
        switch source
          when 'atm'
            thumb = "#{base}/#{root}/answer-key/preview/page-#{scan}-thumbnail.jpeg"
            full = "#{base}/#{root}/answer-key/preview/page-#{scan}-preview.jpeg"
            alt = "##{j + 1}"
          when 'vault'
            thumb = "#{base}/#{scan}/#{scan}-thumb.jpeg"
            full = "#{base}/#{scan}/#{scan}-answer.jpeg"
            alt = "#{j}"
          when 'frontdesk-yardsticks'
            type = json.preview.mcq[j]
            if type isnt isMcq
              counter = 1
              isMcq = type

            thumb = "#{base}/#{scan}/thumbnail.jpeg"
            full = "#{base}/#{scan}/preview.jpeg"
            alt = if isMcq then "M#{counter++}" else "G#{counter++}"
          when 'locker'
            thumb = "#{base}/#{scan}"
            full = "#{base}/#{scan}"
            alt = "pg-#{j+1}"
          else break

        img = $("<li marker=#{scan}><a href=#{full}><img src=#{thumb} alt=#{alt}></a></li>")
        img.appendTo target

      # Now, call the preview
      preview.execute()
      return true

    # Returns the index of the currently displayed image, starting with 0
    currIndex : (loadedPreview = '#document-preview') ->
      loadedPreview = if typeof loadedPreview is 'string' then $(loadedPreview) else loadedPreview
      return null if loadedPreview.hasClass 'hidden'
      counter = loadedPreview.find '.ppy-counter:first'
      if counter.length isnt 0
        return parseInt(counter.text()) - 1
      else return 0 # => single image preview

    # Returns the DB Id of the question being viewed currently 
    currDBId : (loadedPreview = '#document-preview') ->
      index = preview.currIndex()
      return null if index is null
      start = $(loadedPreview).find '.ppy-imglist:first'
      current = start.children('li').eq(index)
      return current.attr 'marker'

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

    softSetImgCaption : (newCaption, loadedPreview = '#document-preview') ->
      loadedPreview = if typeof loadedPreview is 'string' then $(loadedPreview) else loadedPreview
      return null if loadedPreview.hasClass 'hidden'
      caption = loadedPreview.find '.ppy-text:first'
      return null if caption.length is 0
      caption.text newCaption
      return true

    scrollImg: (images, event) ->
      verticalTabs = $('#side-panel').find '.vertical-tabs:first > ul' # if present, we need the ui-tabs-nav
      unless verticalTabs.length is 0
        numTabs = verticalTabs.find('li').length
        index = verticalTabs.find('li.ui-tabs-selected').index()
        next = (index + 1) % numTabs
        prev = if index > 0 then index - 1 else numTabs - 1

      key = event.keyCode
      switch key
        when 66 # 66 = 'B' for going back 
          backBtn = images.find '.ppy-prev:first'
          unless backBtn.length is 0
            backBtn.click()
            verticalTabs.children('li').eq(prev).children('a:first').click() if prev?
        when 78 # 78 = 'N' for going to next
          fwdBtn = images.find '.ppy-next:first'
          unless fwdBtn.length is 0
            fwdBtn.click()
            verticalTabs.children('li').eq(next).children('a:first').click() if next?
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
        when 37 # 37 = left-key 
          next = if currPg > 0 then currPg - 1 else nQues - 1
        when 39 # 39 = right-key
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
