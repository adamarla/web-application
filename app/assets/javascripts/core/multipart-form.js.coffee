
window.multiform = {
  root: null, 
  controls: null,
  parts : null,
  index : 0, 
  last : null,

  initialize : (id) ->
    obj = $(id)[0]
    return false unless obj?

    valid = if obj.getAttribute('data-multipart')? then true else false
    return false unless valid

    multiform.root = obj 
    multiform.controls = $(obj).children('.controls')[0]
    multiform.parts = $(multiform.root).children('.part')
    multiform.index = 0 
    multiform.last = $(multiform.parts).length()
    return true 
    
  enable : (n) ->
    return false unless multiform.root? 
    return false if (n >= multiform.last || n < 0) 
    $(m).addClass('hide') for m in $(multiform.parts)
    $(multiform.parts).eq(n).removeClass('hide')
    multiform.index = n
    return true

  rewind : () ->
    return multiform.enable(0)

  prev : () ->
    return multiform.enable(multiform.index - 1)
      
  next : () ->
    return multiform.enable(multiform.index + 1)
}
