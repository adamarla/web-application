

window.demo = {
  root : null,

  initialize : (json) ->
    demo.root = $('#m-demo') unless demo.root?
    radioBtns = demo.root.find "input[type='radio']"

    for m in radioBtns
      $(m).parent().removeClass 'disabled'
      $(m).prop 'disabled', false

    return true unless json?

    # Disable demos that have been used 
    for d in json
      radio = radioBtns.filter("[value=#{d.id}]").eq(0)
      radio.prop 'disabled', true
      radio.parent().addClass 'disabled'
      
    # Update the download PDF paths
    demo.setDownloadUrls json
    return true

  setDownloadUrls : (json) ->
    downloadLnks = demo.root.find "a[marker]"

    for j in json
      a = downloadLnks.filter("[marker=#{j.id}]").eq(0)
      a.removeClass 'disabled'
      href = a.attr 'href'
          
      a.attr 'href', j.path
      a.attr 'target', "_blank"
      
      # stop any stopwatch 
      watch = a.siblings('.stopwatch')[0]
      if watch?
        $(watch).text "Ready"
        stopWatch.stop watch
    return true

  update : (json) ->
    radioBtns = demo.root.find "input[type='radio']"

    for m in json
      radio = radioBtns.filter("[value=#{m.id}]").eq(0)
      radio.parent().addClass 'disabled'
      radio.prop 'disabled', true

    demo.setDownloadUrls json
    return true
}
