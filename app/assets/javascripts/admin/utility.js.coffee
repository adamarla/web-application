
window.admin = {

  build : {
    ###
    list : {
      pendingScans: (json) ->
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
    ###

    list : (json, within, keys = [], parent = null) ->
      return false if not keys instanceof Array

      # 1. Two keys - marker & class have to be present
      # 2. Another 2 keys - name & parent are highly likely to be present
      # 3. Any other key is case-specific
      # We therefore append (1) and (2) anyways so that the developer only need specify (3)

      keys = keys.concat ['marker', 'class', 'name', 'parent']

      within = if typeof within is 'string' then $(within) else within
      for r in json
        if r instanceof Array then r = r[0]
        e = "<div" # start a self-closing div, that is <div ... />
        for k in keys
          e = "#{e} #{k}=#{r[k]}" if r[k]?
        e = "#{e}/>" # close the div

        if r.parent? and parent?
          target = within.find(parent).filter("[marker=#{r.parent}]").eq(0)
          $(e).appendTo target if target?
        else
          $(e).appendTo within
      return true
  } # end of build 

}
