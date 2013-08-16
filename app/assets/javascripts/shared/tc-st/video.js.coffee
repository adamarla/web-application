

window.video = { 
  last : null,
  get : {
    anchorTag : (uid) ->
      a = "<a href='##{uid}' class='sublime' data-uid='#{uid}' data-youtube-id='#{uid}'></a>"
      return a

    videoTag : (uid) ->
      v = "<video id='#{uid}' data-uid='#{uid}' data-youtube-id='#{uid}' preload='none' width='640' height='360' style='display:none'></video>"
      return v
  }
}

jQuery ->
  sublime.load()

  sublime.ready -> 
    $('.g-panel').on 'click', '.video', (event) ->
      event.stopImmediatePropagation()

      uid = this.getAttribute 'data-video'
      return false unless uid?

      vnode = $(this).children('video')[0]
      unless vnode?
        aTag = video.get.anchorTag(uid)
        vTag = video.get.videoTag(uid)

        $(aTag).appendTo $(this)
        $(vTag).appendTo $(this)

      $(this).addClass 'selected'
      aTag = $(this).children('a.sublime')[0]

      # Unload the last played video
      if video.last?
        sublime.unprepare video.last
        parent = $(video.last).closest('.video').eq(0)
        parent.removeClass('selected')

      video.last = aTag
      sublime.prepare aTag, (lightbox) ->
        lightbox.open()
      return true
      

