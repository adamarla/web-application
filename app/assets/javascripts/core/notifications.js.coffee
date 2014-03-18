
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
          textToRender = json.notify[type]
          if textToRender?
            t = $(notifier.current).find("[class~=#{type}]")[0]
            $(t).text(textToRender) if t?

#  Following code allows LaTeX to be rendered within notifications
#  Works reasonably well - but not perfectly 

#            if t.length isnt 0 
#              if karo.isPlainTextCheck textToRender
#                textToRender = karo.unjaxify textToRender
#                t.text textToRender
#              else
#                t.empty() # clear any old TeX comments
#                id = "tex-notice-#{parseInt(Math.random() * 1000)}"
#                script = $("<script id=#{id} type='math/tex'>#{textToRender}</script>")
#                $(script).appendTo t
#                MathJax.Hub.Queue ['Typeset', MathJax.Hub, "#{id}"]

    # autoHideIn = notifier.current.dataset.autohide
    autoHideIn = notifier.current.getAttribute('data-autohide')

    if autoHideIn? and autoHideIn isnt 'never'
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

