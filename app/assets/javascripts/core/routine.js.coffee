
###
  Definitions of functions that are called routinely and from anywhere
  'within' is a jQuery object - not a string
###

window.enableRadio = (within) ->
  $(m).prop 'disabled', false for m in within.find "input[type='radio']"
  return true

window.disableRadio = (within) ->
  $(m).prop 'disabled', true for m in within.find "input[type='radio']"
  return true

window.enableChecks = (within) ->
  $(m).prop 'disabled', false for m in within.find "input[type='checkbox']"
  return true

window.disableChecks = (within) ->
  $(m).prop 'disabled', true for m in within.find "input[type='checkbox']"
  return true

window.clickChecks = (within) ->
  $(m).prop 'checked', true for m in within.find "input[type='checkbox']"
  return true

window.unclickChecks = (within) ->
  $(m).prop 'checked', false for m in within.find "input[type='checkbox']"
  return true

window.unclickRadio = (within) ->
  $(m).prop 'checked', false for m in within.find "input[type='radio']"
  return true

window.cloak = (within, selector = ".swiss-knife") ->
  # 'selector' is a string. Don't rename this method as 'hide'. That is a jQuery method
  $(m).addClass 'hidden' for m in within.find "#{selector}:not([keep])"
  return true

window.doNothing = (within = null) ->
  return true

window.retain = (obj) ->
  obj.attr 'keep', 'yes' if obj?
  return true

window.block = (obj, selector = null) ->
  return false unless obj?

  if selector?
    $(m).addClass 'disabled' for m in obj.find(selector)
  else
    obj.addClass 'disabled'

  obj.addClass 'disabled'
  disableRadio obj
  disableChecks obj
  return true

window.unblock = (obj) ->
  return false unless obj?

  if selector?
    $(m).removeClass 'disabled' for m in obj.find(selector)
  else
    obj.removeClass 'disabled'

  enableRadio obj
  enableChecks obj
  return true
