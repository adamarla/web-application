
window.admin = {

  build : {

    pendingScanList: (json) ->
      here = $('#list-pending')
      here.empty() # purge any old lists
      for item in json
        e = $("<div scan=#{item.scan}/>")
        for id, index in item.indices
          questionLabel = item.labels[index]

          if item.mcq[index] is true
            $("<div response_id=#{id} mcq='true' qLabel='#{questionLabel}'/>").appendTo(e)
          else
            $("<div response_id=#{id} qLabel='#{questionLabel}'/>").appendTo(e)
        e.appendTo here
      nImages = here.children('div[scan]').length
      here.attr 'length', nImages
      here.attr 'current', 0
      return true
  }

}
