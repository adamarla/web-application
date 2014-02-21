
###
  All notifications are shown as slide-down modals. 
  Notifications respond to json - if provided. However the JSON must be of the 
  following form: 

    :notify => { :title => ..., :msg => ...., :data => ... }

  :title (mandatory)
  :msg, :data (optional)
###

window.notifier = {
  ticker : null,
  current : null,

  show : (obj, json = null) ->
    # Show only one notification at a time. If the notification auto-hides, then 
    # it would persist for only 3 seconds. Otherwise, let the new notification 
    # take precedence over any old notification

    notifier.hide() if notifier.current?
    notifier.current = if typeof obj is 'string' then $("##{obj}")[0] else obj

    if json?
      if json.notify?
        for type in ['title', 'msg']
          if json.notify[type]
            t = $(notifier.current).find("[class~=#{type}]").eq(0)
            t.text(json.notify[type]) if t.length isnt 0


    # autoHideIn = notifier.current.dataset.autohide
    autoHideIn = notifier.current.getAttribute('data-autohide')

    if autoHideIn?
      autoHideIn = parseInt(autoHideIn)
      notifier.ticker = window.setInterval () -> notifier.hide(),
      autoHideIn

    $(notifier.current).removeClass 'hide'
    $(notifier.current).modal 'show'
    return true

  hide : () ->
    if notifier.ticker?
      window.clearTimeout notifier.ticker
      notifier.ticker = null
    if notifier.current?
      $(notifier.current).modal('hide')
      $(notifier.current).addClass 'hide'
      notifier.current = null
    return true
}

