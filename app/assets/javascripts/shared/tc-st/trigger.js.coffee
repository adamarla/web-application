
window.postUpload = (modal) -> # written as onload in modal/teachers/_suggestion.html.haml
  target = $("##{modal}")
  target.find("input[type='file']").eq(0).val null
  target.modal 'hide'
  return true

resetUploader = (btn) ->
  btn.attr 'disabled', false
  pb = btn.find('.progress').eq(0)
  pb.children().eq(0).css 'width', '0%'
  pb.addClass 'hide'
  return true

clickUploader = (btn) ->
  return false if btn.attr('disabled')?
  btn.attr 'disabled', true
  pb = btn.find('.progress').eq(0)
  pb.removeClass 'hide'
  return true

updateProgress = (btn, loaded, total) ->
  pb = btn.find('.progress > .bar').eq(0)
  done = (loaded / total) * 100
  pb.css "width", "#{done}%"
  return true

jQuery ->
  
  $('#btn-show-solution').click (event) ->
    already = $(this).hasClass 'active'
    wsId = this.getAttribute 'data-ws'
    student = this.getAttribute 'data-id'

    if already
      id = this.getAttribute 'data-id'
      $(this).text "See Solution"
      karo.empty $(this).closest('.navbar').next()
      $.get "ws/layout.json?ws=#{wsId}&id=#{id}"
    else
      $(this).text "Back to Scans"
      $.get "ws/preview.json?id=#{wsId}&student=#{student}"
    return true

  $('#btn-video-solution').click (event) ->
    event.stopImmediatePropagation()
    video.play this
    return true

  ###
    Three buttons used for uploading
  ###

  btnScnUpload = $('#btn-upload-scans')
  btnSgUpload = $('#btn-upload-sg')
  btnQuickTrialUpload = $('#btn-quick-trial-upload')

  scnUploader = new qq.FileUploaderBasic {
    button : btnScnUpload[0],
    action : "#{gutenberg.server}/Upload/scan",

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
    action : "#{gutenberg.server}/Upload/suggestion",
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

  quickTrialUploader = new qq.FileUploaderBasic {
    button : btnQuickTrialUpload[0],
    action : "#{gutenberg.server}/Upload/scan",

    onSubmit : (id, filename) ->
      return clickUploader(btnQuickTrialUpload)

    onProgress : (id, fileName, loaded, total) ->
      return updateProgress(btnQuickTrialUpload, loaded, total)

    onComplete : (id, filename, json) ->
      resetUploader btnQuickTrialUpload
      return true

    onError : (id, filename, xhr) ->
      resetUploader btnQuickTrialUpload
      return true
  }
