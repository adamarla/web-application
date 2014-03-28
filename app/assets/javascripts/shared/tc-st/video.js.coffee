

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

  unload : (obj) ->
    # Removes any previously added <a> and <video> nodes within $(obj). 
    # Needed when the same trigger is shared amongst many videos

    return false unless $(obj).hasClass 'video'
    $(m).remove() for m in $(obj).children('.sublime, video')
    return true

  play : (obj) ->
    return false unless $(obj).hasClass 'video'
    uid = obj.getAttribute 'data-video'
    return false unless uid?

    vnode = $(obj).children('video')[0]
    unless vnode?
      aTag = video.get.anchorTag(uid)
      vTag = video.get.videoTag(uid)

      $(aTag).appendTo $(obj)
      $(vTag).appendTo $(obj)

    aTag = $(obj).children('a.sublime')[0]

    # Unload the last played video
    sublime.unprepare video.last if video.last?

    video.last = aTag
    sublime.prepare aTag, (lightbox) ->
      lightbox.open()
    return true
}

###
jQuery ->
  sublime.load()

  sublime.ready -> 
    $('.g-panel').on 'click', '.video', (event) ->
      event.stopImmediatePropagation()
      return video.play(this) 
      
###

