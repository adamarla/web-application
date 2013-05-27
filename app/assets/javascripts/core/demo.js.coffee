

window.demo = {
  root : null,

  initialize : (json) ->
    demo.root = $('#m-demo') unless demo.root?
    radioBtns = demo.root.find "input[type='radio']"

    for m in radioBtns
      $(m).parent().addClass 'disabled'
      $(m).prop 'disabled', true

    # Enable available demos 
    for m in json.build
      radio = radioBtns.filter("[value=#{m}]").eq(0)
      radio.prop 'disabled', false
      radio.parent().removeClass 'disabled'

    # Update the download PDF paths
    demo.setDownloadUrls json.download
    return true

  setDownloadUrls : (json) ->
    downloadLnks = demo.root.find "a[marker]"

    for j in json
      a = downloadLnks.filter("[marker=#{j.id}]").eq(0)

      a.removeClass 'disabled'
      href = a.attr 'href'
          
      # Update the download worksheet PDF link 
      for key in ['a', 'b', 'c']
        break unless j[key]? # no :b if no :a, no :c if no :b etc
        while href.search(":#{key}") isnt -1
          href = href.replace ":#{key}", j[key]
      a.attr 'href', href
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
