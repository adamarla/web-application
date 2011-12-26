
window.loadSyllabiEditFormWith = (syllabi) ->
  table = $('#edit-syllabi-megaform')

  for item in syllabi
    topic = item.syllabus.id
    difficulty = item.syllabus.difficulty
    target = table.find "div[marker=#{topic}]"

    continue if target.length is 0

    checkbox = target.find('.checkbox:first').children('input:first')
    dropdown = target.find('.dropdown:first').find('select:first')
    option = dropdown.find "option[value=#{difficulty}]:first"

    checkbox.prop 'checked', true
    dropdown.prop 'disabled', false
    option.prop 'selected', true

window.buildSyllabiEditForm = (json) ->
  startPt = $('#edit-syllabi-form')
  $(node).empty() for node in startPt.find('.peek-a-boo:first')

  for m in json
    macro = m.macro
    target = if macro.in is true then startPt.find('.peek-a-boo:first') else startPt.find('.dump:first')
    newNode = $('<div/>', { class : 'hidden', marker : macro.id})
    newNode.appendTo target
    displayJson macro.micros, newNode, 'micro', false, true, true

###
  Shows the list of macros covered by a course. The passed JSON
  is assumed to have at least 2 fields : id (of the macro) and a 
  boolean 'in' for whether or not the macro is covered in a course
###

window.displayMacroList = (json, options = {radio:true, checkbox:false, select:false, button:false}) ->
  start = $('#macro-topic-list')
  for record in json
    macro = record['macro']
    covered = macro.in
    id = macro.id

    chosenOne = start.find ".swiss-knife[marker=#{id}]:first"
    customizeGodElement chosenOne, options
    within = chosenOne.closest '.sortable'

    if within.length is 0 #initially
      if covered is true
        target = start.find '.in-tray:first'
        disabled = false
      else
        target = start.find '.out-tray:first'
        disabled = true
    else if within.hasClass 'in-tray'
      continue if covered is true # leave untouched
      target = start.find '.out-tray:first'
      disabled = true
    else
      continue if covered is false # leave untouched
      target = start.find '.in-tray:first'
      disabled = false

    chosenOne = chosenOne.detach()
    chosenOne.appendTo $(target)

    for element in chosenOne.children()
      continue if $(element).hasClass 'hidden'
      $(element).prop 'disabled', disabled
