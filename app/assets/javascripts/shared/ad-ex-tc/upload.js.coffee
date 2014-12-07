

window.upload = { 
  buttons : null, 

  button : { 
    find : (btnId) ->
      return null unless upload.buttons? 
      for b in upload.buttons 
        return b if $(b.button).attr('id') is btnId 
      return null 

    add : (btnId, url, refNd = null, params = null) -> 
      upload.buttons = new Array() unless upload.buttons?
      nd = upload.button.find btnId 
      return false if nd?
      btn = $("##{btnId}")[0]
      return false unless btn?

      ref = if refNd? then $("##{refNd}")[0] else null 
      nd = new qq.FileUploaderBasic {
        button : btn, 
        action : url,
        ref : ref,
        params : if params? then $.extend({}, params) else {} # copy an common params

        onSubmit : (id, filename) ->
          this.params.id = $(this.ref).attr('marker') if this.ref?
          return upload.tracking.start(this.button)

        onProgress : (id, filename, loaded, total) ->
          return upload.tracking.update(this.button, loaded, total)

        onComplete :(id, filename, json) ->
          return upload.tracking.stop(this.button)

        onError : (id, filename, xhr) ->
          return upload.tracking.stop(this.button)
      } 
      # Push the file-uploader object into the array
      upload.buttons.push nd 
      return true 
  } 

  tracking : { 
    start : (btn) ->
      return false if $(btn).attr('disabled')?
      $(btn).attr 'disabled', true
      pb = $(btn).find('.progress')[0]
      return false unless pb? 
      $(pb).removeClass 'hide'
      return true

    update : (btn, loaded, total) ->
      pb = $(btn).find('.progress > .bar')[0]
      return false unless pb?
      done = (loaded / total) * 100
      $(pb).css "width", "#{done}%"
      return true

    stop : (btn) ->
      $(btn).attr 'disabled', false
      pb = $(btn).find('.progress')[0]
      return false unless pb? 
      $(pb).children().eq().css 'width', '0%'
      $(pb).addClass 'hide'
      return true


  } 
} 
