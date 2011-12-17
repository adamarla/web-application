
emptyMe = (node) -> node.empty() 

putBack = (node) -> 
  node = node.detach() 
  node.appendTo '#toolbox'

clearPanel = (id, moveAlso = true) ->
  me = $(id).children().first() 
  return if me.length is 0

    # If 'me' has any data under a <div class="data empty-on-putback"> within its 
    # hierarchy, then empty that data first. Note, that it is assumed that 
    # the emptied out data can re-got from an AJAX query. In other words, 
    # if some data is too valuable to lose, then *do not* put it under 
    # .data.empty-on-putback

  emptyMe node for node in me.find('.data.empty-on-putback')
  putBack me if moveAlso is true


window.refreshView = (linkId) -> 
  link = $('#' + linkId) 

  for type in ['side', 'middle', 'right', 'wide'] 
    needed = link.attr type
    target = '#' + type + '-panel'
    
    continue if link.hasClass('minor-link') and needed is 'side' 
    loaded = $(target).children().first() 
    continue if loaded is $(needed) 
    
    clearPanel target

    if not needed?  
      $(target).addClass('hidden') 
    else 
      $(target).removeClass('hidden') 
      $(needed).appendTo(target).hide().fadeIn('slow')

setUrlOn = (radio, url) -> 
  radio.attr 'url', (url + radio.attr 'marker')

resetRadiosUrlsIn = (panel, url) -> 
  setUrlOn radio for radio in $(panel).find 'input[type="radio"]' when radio.attr 'marker' isnt null

