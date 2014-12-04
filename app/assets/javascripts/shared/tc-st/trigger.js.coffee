
window.postUpload = (modal) -> # written as onload in modal/teachers/_suggestion.html.haml
  target = $("##{modal}")
  target.find("input[type='file']").eq(0).val null
  target.modal 'hide'
  return true

jQuery ->
  upload.button.add('btn-upload-scans', "#{gutenberg.server}/Upload/scan")
  upload.button.add('btn-upload-sg', "#{gutenberg.server}/Upload/suggestion", 'control-panel')

