
window.sandbox = { 
  enabled : false
}

jQuery ->
  
  $('#btn-sandbox-toggle').click (event) ->
    event.stopImmediatePropagation() 
    isActive = $(this).hasClass 'active'

    if isActive
      $(this).text 'Sandbox Off'
      $(this).removeClass 'active'
      sandbox.enabled = false
    else
      $(this).text 'Sandbox On' 
      $(this).addClass 'active'
      sandbox.enabled = true
      notifier.show 'n-sandbox-tips'
    return true


