
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
    # show only one notification at a time. If the notification auto-hides, then 
    # it would persist for only 3 seconds. Unlikely that the user would do anything
    # in that time that could spawn another notification. Unless, of course the user
    # is an idiot / child and presses the same button again and again 

    return true if notifier.current?
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

###
window.notifier = {
  obj : null,
  target : null,
  ticker : null,

  initialize : () ->
    return false if obj?
    notifier.obj = $('#control-panel').find('#m-notifications').eq(0)
    notifier.target = $('#toolbox').find('#notifications').eq(0)
    return true

  add : (json) ->
    notifier.initialize() unless notifier.obj?
    return false unless json.notify?
    return false unless json.notify.text?

    date = new Date()
    hours = date.getHours()
    min = date.getMinutes()

    if hours > 12
      ampm = "PM"
      hours -= 12
    else
      ampm = "AM"

    min = if min > 10 then min else "0#{min}"

    li = $("<li class='notice'></li>").prependTo notifier.target
    $("<div class='text'>#{hours}:#{min} #{ampm} - #{json.notify.text}</div>").appendTo li

    if json.notify.subtext?
      $("<div class='offset2 subtext'>#{json.notify.subtext}</div>").appendTo li

    # get the notifier to start blinking - unless already
    unless notifier.ticker?
      notifier.ticker = self.setInterval () -> notifier.blink(),
      1000
    return true

  blink : () ->
    if notifier.obj.hasClass('on') then notifier.obj.removeClass('on') else notifier.obj.addClass('on')
    return true

}

jQuery ->

  # other than opening the menu, also stop notifier blinking
  $('#m-notifications').click ->
    window.clearInterval(notifier.ticker) if notifier.ticker?
    notifier.obj.removeClass 'on'
    notifier.ticker = null
    return true

  # Any ajaxSuccess that returns a JSON with :notify should be captured here

  $('#control-panel').ajaxSuccess (e,xhr,settings) ->
    json = $.parseJSON xhr.responseText
    if json.notify?
      notifier.add json
    return true


