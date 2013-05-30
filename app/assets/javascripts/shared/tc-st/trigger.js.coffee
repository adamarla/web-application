
window.postUpload = (modal) -> # written as onload in modal/teachers/_suggestion.html.haml
  target = $("##{modal}")
  target.find("input[type='file']").eq(0).val null
  target.modal 'hide'
  return true

resetUploader = (btn) ->
  btn.attr 'disabled', false
  pb = btn.find('.progress > .bar').eq(0)
  pb.css 'width', '0%'
  return true

clickUploader = (btn) ->
  return false if btn.attr('disabled')?
  btn.attr 'disabled', true
  return true

updateProgress = (btn, loaded, total) ->
  pb = btn.find('.progress > .bar').eq(0)
  done = (loaded / total) * 100
  pb.css "width", "#{done}%"
  return true

jQuery ->
  
  $('#btn-show-solution').click (event) ->
    already = $(this).hasClass 'active'
    #ws = $("##{this.dataset.ws}")
    ws = $("##{this.getAttribute('data-ws')}")
    wsId = ws.attr('marker') || ws.parent().attr('marker')

    if already
      # student = $("##{this.dataset.id}")
      student = $("##{this.getAttribute('data-id')}")
      id = student.attr('marker') || student.parent().attr('marker')
      $(this).text "See Solution"
      karo.empty $(this).parent().next()
      $.get "ws/layout.json?ws=#{wsId}&id=#{id}"
    else
      $(this).text "Back to Scans"
      $.get "ws/preview.json?id=#{wsId}"

    return true


  btnScnUpload = $('#btn-upload-scans')
  btnSgUpload = $('#btn-upload-sg')

  scnUploader = new qq.FineUploaderBasic {
    button : btnScnUpload[0],
    request : {
      endpoint : "http://10.10.0.16:8080/ScanUploader/uploadScan"
    },

    callbacks : {
      onSubmit : (id, filename) ->
        return clickUploader(btnScnUpload)

      onProgress : (id, fileName, loaded, total) ->
        return updateProgress(btnScnUpload, loaded, total)

      onComplete : (id, filename, json) ->
        resetUploader btnScnUpload
        return true

      onError : (id, filename, xhr) ->
        resetUploader btnScnUpload
        return true
    }
  }

  ###
  scnUploader = new qq.FileUploaderBasic {
    button : btnScnUpload[0],
    action : "http://10.10.0.16:8080/ScanUploader/uploadScan",

    onSubmit : (id, filename) ->
      return clickUploader(btnScnUpload)

    onProgress : (id, fileName, loaded, total) ->
      return updateProgress(btnScnUpload, loaded, total)

    onComplete : (id, filename, json) ->
      resetUploader btnScnUpload
      return true

    onError : (id, filename, xhr) ->
      resetUploader btnScnUpload
      return true
  }

  sgUploader = new qq.FileUploaderBasic {
    button : btnSgUpload[0],
    # action : "http://10.10.0.17:8080/ScanUploader/uploadScan",
    action : "#{rails.server}/suggestion",
    params : {
      id : $('#control-panel').attr('marker')
    },

    onSubmit : (id, filename) ->
      return clickUploader(btnSgUpload)

    onProgress : (id, fileName, loaded, total) ->
      return updateProgress(btnSgUpload, loaded, total)

    onComplete : (id, filename, json) ->
      resetUploader btnSgUpload
      return true

    onError : (id, filename, xhr) ->
      resetUploader btnSgUpload
      return true
  }
  ###

