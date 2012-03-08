
jQuery ->
  
  window.preview = {

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
      indices = json.preview.indices

      for index,j in indices
        switch source
          when 'atm'
            thumb = "#{base}/#{root}/answer-key/preview/page-#{index}-thumbnail.jpeg"
            full = "#{base}/#{root}/answer-key/preview/page-#{index}-preview.jpeg"
            alt = "##{index + 1}"
          when 'vault'
            thumb = "#{base}/#{index}/#{index}-thumb.jpeg"
            full = "#{base}/#{index}/#{index}-answer.jpeg"
            alt = "#{index}"
          when 'frontdesk-yardsticks'
            thumb = "#{base}/#{index}/thumbnail.jpeg"
            full = "#{base}/#{index}/preview.jpeg"
            alt = "#{j.toString(16).toUpperCase()}"
          when 'locker'
            thumb = "#{base}/#{j}"
            full = "#{base}/#{j}"
            alt = "page ##{index}"
          else break

        img = $("<li marker=#{index}><a href=#{full}><img src=#{thumb} alt=#{alt}></a></li>")
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


  }
