
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
      return true

    execute : () ->
      p = $('#document-preview')
      return if p.parent().hasClass '.ppy-placeholder'
      p.popeye({ navigation : 'permanent', caption : 'permanent'})

    loadJson : (json, key = 'question') ->
      baseUrl = "https://github.com/abhinavc/RiddlersVault/raw/master"
      preview.initialize()

      target = $('#document-preview').find 'ul:first'
      for record in json
        data = record[key]
        relPath = data.name # actually, its the path
        folder = relPath.split('/').pop() # from X/Y/1_5, extract 1_5
        full = "#{baseUrl}/#{relPath}/#{folder}-answer.jpeg"
        thumb = "#{baseUrl}/#{relPath}/#{folder}-thumb.jpeg"

        img = $("<li marker=#{data.id}><a href=#{full}><img src=#{thumb} alt=#{folder}/></a></li>")
        img.appendTo target

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
