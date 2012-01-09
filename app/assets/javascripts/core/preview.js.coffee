
jQuery ->
  
  window.preview = {

    initialize : () ->
      # Call Popeye on #document-preview. The internals will be filled in later
      $('#document-preview').popeye()
      return true

    loadJson : (json, key = 'question') ->
      baseUrl = "https://github.com/abhinavc/RiddlersVault/raw/master"
      target = $('#document-preview').find 'ul:first'

      # Empty the target to make space for a new list
      target.empty()

      for record in json
        data = record[key]
        relPath = data.name # actually, its the path
        folder = relPath.split('/').pop() # from X/Y/1_5, extract 1_5
        full = "#{baseUrl}/#{relPath}/#{folder}-answer.jpeg"
        thumb = "#{baseUrl}/#{relPath}/#{folder}-thumb.jpeg"

        preview = $("<li><a href=#{full}><img src=#{thumb} alt=#{folder}/></a></li>")
        preview.appendTo target

      ###
        If popeye() was called once before, then don't call it again on #document-preview.
        If you do, then the border around the preview will get thicker and thicker.
        Other weird stuff can happen too
      ###

      ppy = $('#document-preview').closest '.ppy-placeholder'
      if ppy.length is 0
        $('#document-preview').popeye()
      return true
  }
