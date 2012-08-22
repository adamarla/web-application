
###
  Definitions of functions that are called routinely and from anywhere
  'within' is a jQuery object - not a string
###

window.disableRadio = (within) ->
  $(m).prop 'disabled', true for m in within.find "input[type='radio']"
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
