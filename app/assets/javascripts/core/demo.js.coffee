

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
    return true

  update : (json) ->
    return true
}
