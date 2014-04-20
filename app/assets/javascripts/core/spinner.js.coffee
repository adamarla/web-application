
window.spinner = {
  root: null, 
  dom : null,
  obj : null,
  text: null, 
  subtext: null,

  initialize : () ->
    unless spinner.root?
      spinner.root = $('body > #spinner')[0]
      spinner.dom = $(spinner.root).children()[0]
      settings = { 
        lines: 10, # The number of lines to draw
        length: 8, # The length of each line
        width: 4, # The line thickness
        radius: 10, # The radius of the inner circle
        color: '#fff', # #rgb or #rrggbb or array of colors
        position: 'relative'
      }
      spinner.obj = new Spinner(settings)
    return true

  setText : (something = null) -> 
    spinner.text = something
    return true
    
  setSubtext : (something = null) -> 
    spinner.subtext = something
    return true

  reset : () ->
    spinner.text = null
    spinner.subtext = null
    return true 

  start : () -> 
    spinner.initialize()
    txt = if spinner.text? then spinner.text else 'Loading'
    $(spinner.root).find('.text').eq(0).text txt
    
    sbtxt = if spinner.subtext? then spinner.subtext else ''
    $(spinner.root).find('.subtext').eq(0).text sbtxt
    $(spinner.root).show()
    spinner.obj.spin(spinner.dom)
    return true

  stop : () ->
    spinner.reset()
    if spinner.root?
      spinner.obj.stop()
      $(spinner.root).hide()
    return true
}
