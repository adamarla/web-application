
###
  Notifications are * always * shown in the same place 
  in the control panel and * always * as a dropdown

  The dropdown is * always * an <a> with id = 'm-notifications'

  The JSON below should also be of the form 
    :notify => { :text => ..., :subtext => ...., :data => ... }
  :text (mandatory)
  :subtext, :data (optional)
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

    li = $("<li class='notice'></li>").prependTo notifier.target
    $("<div class='text'>#{hours}:#{min} - #{json.notify.text}</div>").appendTo li

    if json.notify.subtext?
      $("<div class='subtext'>#{json.notify.subtext}</div>").appendTo li

    # get the notifier to start blinking
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
    return true
