
window.stopWatch = {
  watches : [],
  masterClock : null,

  initialize : () ->
    unless stopWatch.masterClock
      stopWatch.masterClock = setInterval () -> stopWatch.update(),
      1000
    return true

  find : (domObj) ->
    for m in stopWatch.watches
      return m if m.dom is domObj
    return null

  add : (domObj) ->
    return false unless $(domObj).hasClass 'stopwatch'
    return false if stopWatch.find(domObj)?

    obj = new Object()
    obj.dom = domObj
    obj.time = -1
    obj.active = false
    obj.fwd = false # (default) count-down. Set to true to count-up
    stopWatch.watches.push obj
    return true

  start: (domObj, seconds, fwd = false) ->
    obj = stopWatch.find domObj
    return false unless obj?

    obj.time = seconds
    obj.fwd = fwd
    obj.active = true
    return true

  stop : (domObj) ->
    obj = stopWatch.find domObj
    return false unless obj?

    obj.active = false
    return true

  update : (obj) ->
    for m in stopWatch.watches
      continue unless m.active
      
      if m.time < 1 # this stopWatch should have stopped by now. Why is it still on?
        m.active = false
        continue

      m.time = if m.fwd then (m.time + 1) else (m.time - 1)
      asString = stopWatch.display m.time
      $(m.dom).text asString
    return true

  display : (time) ->
    # Returns stored seconds in hh:mm:ss format
    hours = Math.floor(time / 3600)
    minutes = Math.floor((time % 3600) / 60)
    seconds = time % 60

    h = if hours > 9 then "#{hours}" else "0#{hours}"
    m = if minutes > 9 then "#{minutes}" else "0#{minutes}"
    s = if seconds > 9 then "#{seconds}" else "0#{seconds}"
    return "#{h}:#{m}:#{s}"

}
